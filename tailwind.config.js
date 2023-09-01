import typographyPlugin from '@tailwindcss/typography';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./assets/**/*.{js,ts,jsx,tsx}",
    "./source/**/*.{html,erb}",
  ],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [
    typographyPlugin,
  ],
}
