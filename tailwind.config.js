import typographyPlugin from '@tailwindcss/typography';

import colors from './config/colors.json';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./assets/**/*.{js,ts,jsx,tsx}",
    "./source/**/*.{html,erb}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors,
      spacing: {
        18: '4.5rem',
      },
    },
  },
  plugins: [
    typographyPlugin,
  ],
}
