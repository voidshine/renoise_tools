use std::path::Path;

use crate::prelude::*;
use fire::midi_message::ToMidiMessage;
use fire::resources::Resources;

const FONT_MEGAMAN: &str = include_str!("../content/MEGAMAN10.json");

pub fn load_image_sysex<P: AsRef<Path>>(path: P) -> Res<MidiMessage> {
    let bitmap = LedBitmap::from_image_file(path)?;
    Ok(BitmapView::new(&bitmap, ScreenRect::full()).to_midi_message())
}

#[derive(Clone, Eq, PartialEq)]
pub struct LedRenderModel {
    pub draw_commands: Vec<DrawCommand>,
}

#[derive(Clone)]
struct DeviceState {
    model: LedRenderModel,
    led_state: LedState,
    led_state_sent: LedState,
}

impl DeviceState {
    fn new() -> Self {
        Self {
            model: LedRenderModel {
                draw_commands: vec![],
            },
            led_state: LedState::new(),
            led_state_sent: LedState::new(),
        }
    }

    fn get_full_sysex(&mut self) -> MidiMessage {
        self.led_state_sent = self.led_state.clone();
        self.led_state.get_full_sysex()
    }

    fn get_update_sysex(&mut self) -> Option<MidiMessage> {
        let update = self.led_state.get_update_sysex(&self.led_state_sent);
        self.led_state_sent = self.led_state.clone();
        update
    }
}

pub struct LedStateManager {
    device_states: Vec<DeviceState>,
    resources: Resources,
}

impl LedStateManager {
    pub fn new() -> Self {
        let mut resources = Resources::new();
        // unwrap() is okay while resource is inbuilt.
        resources.load_pentacom_font(FONT_MEGAMAN, true).unwrap();
        resources.load_pentacom_font(FONT_MEGAMAN, false).unwrap();
        Self {
            device_states: vec![DeviceState::new(); 4],
            resources,
        }
    }

    pub fn get_full_sysex(&self, device_index: usize) -> MidiMessage {
        self.device_states[device_index].led_state.get_full_sysex()
    }

    // May return None if there's no change.
    pub fn get_led_update_sysex(&mut self, device_index: usize, model: LedRenderModel) -> Option<MidiMessage> {
        let state = self.device_states.get_mut(device_index)?;
        if state.model != model {
            let mut dc = state.led_state.make_draw_context(&self.resources);
            for command in &model.draw_commands {
                dc.draw(command);
            }
            state.model = model;

            // TODO: dirty part
            state.get_update_sysex()
        } else {
            None
        }
    }
}
