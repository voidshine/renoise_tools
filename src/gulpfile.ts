import * as gulp from 'gulp'
import { exec } from 'child_process'
import * as del from 'del';
import {readFileSync, writeFileSync} from 'fs';

import * as luamin from 'luamin';
import * as transform from 'gulp-transform';

const src = {
    ts: 'pyre/src/**/*.ts',
    raw: 'pyre/src/**/*.{lua,xml}',
    dll: 'rust/pyre/target/release/pyre.dll',
};
const dst = {
    pyre: 'gen/pyre',
    pyre_lua: 'gen/pyre/**/*.lua',
    pyre_main_lua: 'gen/pyre/main.lua',
};

export const clean = () => del('gen');

export const compilePyre = (cb) => {
    exec('yarn build_pyre', cb).stdout.pipe(process.stdout);
};

const copyFiles = () => gulp.src(src.raw).pipe(gulp.dest(dst.pyre));

const hackSourceMap = (cb) => {
    const path = `${dst.pyre}/main.lua`;
    let text = `-- Tweaked during build to work around sourcemaps issue.
__TS__sourcemap = {};
__TS__originalTraceback = debug.traceback;
${readFileSync(path, {encoding: "utf-8"})}
`;
    writeFileSync(path, text, {encoding: "utf-8"});
    cb();
};

export const buildRustPyre = (cb) => {
    exec('cargo build --release', { cwd: 'rust/pyre' }, cb).stdout.pipe(process.stdout);
};

export const copyDll = () => gulp.src(src.dll)
    .pipe(gulp.dest(dst.pyre));

export const minify_lua = () => gulp.src(dst.pyre_lua)
    .pipe(transform({encoding: 'utf8'}, (content, file) => luamin.minify(content)))
    .pipe(gulp.dest(dst.pyre));    

export const buildPyre = gulp.series(
    gulp.parallel(
        // TODO: Fix buildRustPyre to not depend on IDEA task environment for mlua
        //buildRustPyre,
        compilePyre
    ),
    gulp.parallel(
        copyFiles
        // TODO: see buildRustPyre above
        // copyDll
    ),
    hackSourceMap,
    minify_lua,
);

export const watch = gulp.series(
    buildPyre,
    gulp.parallel(
        (cb) => gulp.watch(src.ts, gulp.series(compilePyre, hackSourceMap)),
        (cb) => gulp.watch(src.raw, copyFiles),
        (cb) => gulp.watch(src.dll, copyDll),
    )
);

interface DeploymentConfig {
    destination: string;
    //destinations: string[];
}
export const deployPrototype = () => {
    // TODO: Clean old files; mirror with exceptions.
    const deploymentConfig: DeploymentConfig = JSON.parse(readFileSync('gen/deployment_config.json', {encoding: 'utf-8'}));
    return gulp.src([`${dst.pyre}/**/*`, `!${dst.pyre}/{fire_config.json,pyre_log.txt}`])
        .pipe(gulp.dest(deploymentConfig.destination));
    // Broken
    // return gulp.parallel(deploymentConfig.destinations.map(destination => () => gulp.src([`${dst.pyre}/**/*`, `!${dst.pyre}/fire_config.json`])
    //     .pipe(gulp.dest(destination))));
};

export default buildPyre;
