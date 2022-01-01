declare global {
    let pyre_native: PyreNative;
    let driver: Driver;
}

// External dependencies
import './external/external_declarations';

// Many modules require palette; include it early so they don't all have to require explicitly.
require('palette')

require('global')

import { PyreNative } from './pyre_native';
import { Driver } from './engine/driver';

pyre_native = new PyreNative();
driver = new Driver('fire_config.json');
