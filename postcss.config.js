
import autoprefixer from 'autoprefixer'
import tailwind from 'tailwindcss'

import tailwindConfig from './tailwind.config.js'

// @SEE: https://github.com/vitejs/vite/issues/7808
export default {
  plugins: [
    tailwind(tailwindConfig),
    autoprefixer,
  ],
};
