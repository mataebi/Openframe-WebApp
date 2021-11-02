'use strict';

import baseConfig from './base';

let config = {
  appEnv: 'dist',  // feel free to remove the appEnv property here
  apiBase: process.env.API_HOST,
  crossStorageRules: [
    {
        origin: /localhost:3030$/,
        allow: ['get']
    },
    {
        origin: /editor\.thebookofshaders\.com$/,
        allow: ['get']
    },
    {

        origin: /patriciogonzalezvivo\.github\.io$/,
        allow: ['get']
    }
  ]
};

export default Object.freeze(Object.assign({}, baseConfig, config));
