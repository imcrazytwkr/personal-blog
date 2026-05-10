import fullReloadPlugin from 'vite-plugin-full-reload';
import rubyPlugin from 'vite-plugin-ruby';
import { defineConfig } from 'vite';

import postcss from './postcss.config.js';

export default defineConfig({
  build: {
    emptyOutDir: true,
    minify: 'oxc',
    cssMinify: 'lightningcss',
    rolldownOptions: {
      output: { format: "es" },
    },
    manifest: false,
    reportCompressedSize: false,
  },
  plugins: [
    fullReloadPlugin(["source/**/*", "data/*"]),
    rubyPlugin(),
  ],
  css: { postcss },
});
