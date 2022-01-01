// A single Driver drives all devices that are connected and active.

import { Fire } from './fire';
import { GeneratedMidi } from './generated_midi';
import { Options } from './options';
import { SongData } from './song_data';
import { write_file } from './utility';

export class Driver {
    VERSION_STRING = `V: ${pyre_native.get_version()}`;

    is_started: boolean;
    options: Options;
    song_data: SongData = new SongData();
    fires: Fire[];
    generated_midi: GeneratedMidi;
    coro: LuaThread | null = null;

    constructor(options_filename: string) {
        // print('driver init')

        this.is_started = false;
        this.generated_midi = new GeneratedMidi();

        // TODO: Dynamic count
        this.fires = [new Fire(0), new Fire(1),];

        this.options = new Options(options_filename, (options: Options) => {
            this.on_options_changed(options);
        });

        this.options.load_config()

        renoise.tool().app_new_document_observable.add_notifier(this.on_new_document, this);
        
        renoise.tool().app_saved_document_observable.add_notifier(this.on_saved_document, this);

        // TODO: Use renoise.tool().tool_finished_loading_observable and
        //  renoise.tool().tool_will_unload_observable when available.
        renoise.tool().app_release_document_observable.add_notifier(this.on_release_document, this)

        renoise.tool().add_menu_entry({
            name: "Main Menu:Tools:voidshine pyre:Configure...",
            invoke: () => { this.options.prompt_configuration() }
        });
        renoise.tool().add_menu_entry({
            name: "Main Menu:Tools:voidshine pyre:Reset configuration to default",
            invoke: () => { this.options.reset_to_default() }
        });
    }

    on_new_document() {
        // print('new doc')
        rns = renoise.song();

        this.song_data = SongData.load_from_file();

        assert(!this.is_started);
        this.start();

        // this.fires.forEach((fire, _) => {
        //     fire.on_new_document()
        // }
    }

    on_saved_document() {
        // Only write files if at least one device is active. If none, then the user might just
        // have the tool installed but isn't currently using it. In that case, don't produce clutter.
        if (this.fires.some(fire => fire.is_active)) {
            this.song_data.save_to_file();
        } else {
            if (this.coro == null) {
                this.coro = coroutine.create(() => {
                    const then = os.clock() + 1.5;
                    while (os.clock() < then) {
                        coroutine.yield();
                    }
                    renoise.app().show_status("voidshine pyre data not written (no active Fire devices)");
                });
            }
        }
    }

    on_release_document() {
        // print('release doc')
        if (this.is_started) {
            this.stop()
            // this.fires.forEach((fire, _) => {
            //     fire.on_release_document()
            // }
        }
        
        // TODO: Fix hack.
        rns = null as unknown as renoise.Song;

        pyre_native.shutdown();
    }

    on_options_changed(options: Options) {
        // rprint({["on_options_changed"] = options})
        if (this.is_started) {
            this.fires.forEach((fire, _) => {
                const fire_config = options.get_fire_config(fire.fire_device_index);
                fire.on_fire_config_changed(fire_config);
            });
            this.generated_midi.on_config_changed(options.config.generated_midi);
        } else {
            rprint("options changed while not started");
        }
    }

    on_idle() {
        if (this.coro != null) {
            const [succeeded, error] = coroutine.resume(this.coro);
            if (!succeeded) {
                this.coro = null;
                print('coro', error);
            }
        }

        // TODO: performance analysis
        assert(this.is_started && rns)
        this.fires.forEach((fire, _) => {
            if (fire.is_active) {
                fire.on_idle();
            }
        });
    }

    start() {
        this.is_started = true;

        // this.generated_midi = new GeneratedMidi()

        // No need to manually start fires because they start according to configuration.
        // Just subscribe and options will flow to start fire.
        // this.fires.forEach((fire, _) => {
        //     const fire_config = this.options.get_fire_config(fire.fire_device_index)
        //     fire.start(fire_config)
        // }
        this.on_options_changed(this.options);

        renoise.tool().app_idle_observable.add_notifier(this.on_idle, this);
    }

    stop() {
        renoise.tool().app_idle_observable.remove_notifier(this.on_idle, this);
        this.is_started = false;
        this.fires.forEach((fire, _) => {
            fire.on_fire_config_changed(null);
        });
    }

    invalidate_all_layers() {
        this.fires.forEach(fire => {
            if (fire.is_active) {
                fire.root_layer.invalidate();
            }
        });
    }
}
