'use strict';

import baseConfig from './base';

let config = {
  appEnv: 'dev',  // feel free to remove the appEnv property here
  apiBase: process.env.API_HOST,
  crossStorageRules: [
    {
        origin: /localhost:3030$/,
        allow: ['get']
    }
  ]
};

export default Object.freeze(Object.assign({}, baseConfig, config));
