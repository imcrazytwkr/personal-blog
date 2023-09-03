import fullReloadPlugin from 'vite-plugin-full-reload';
import esbuildPlugin from 'rollup-plugin-esbuild';
import rubyPlugin from 'vite-plugin-ruby';
import { defineConfig } from 'vite';

import postcss from './postcss.config.js';

export default defineConfig({
  build: {
    emptyOutDir: true,
    minify: 'esbuild',
    rollupOptions: {
      plugins: [esbuildPlugin()],
      output: { format: "es" },
    },
    manifest: false,
    reportCompressedSize: false,
  },
  plugins: [
    fullReloadPlugin(["source/**/*", "data/*"], { delay: 1000 }),
    rubyPlugin(),
  ],
  css: { postcss },
})
