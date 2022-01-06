/**
 * @license
 * Copyright 2021 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */

const mode = process.env.MODE || 'dev';
if (!['dev', 'prod'].includes(mode)) {
    throw new Error(`MODE must be "dev" or "prod", was "${mode}"`);
}

module.exports = {
    nodeResolve: { exportConditions: mode === 'dev' ? ['development'] : [] },
    preserveSymlinks: true,
    plugins: [

    ],
};