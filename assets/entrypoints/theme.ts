import colors from '../../config/colors.json';

// base
const htmlClass = document.documentElement.classList;
setTimeout(() => htmlClass.remove('not-ready'), 10);

function getCurrentLightColor() {
  for (const cn in htmlClass) {
    if (!cn.startsWith('bg-')) {
      continue;
    }

    const color = colors[cn.slice(3)];
    if (color) {
      return color as string;
    }
  }

  return colors.linen;
}

const LIGHT_COLOR = getCurrentLightColor();
const DARK_COLOR = '#000000';

// mobile menu
const btnMenu = document.getElementById('button-menu');
if (btnMenu) {
  btnMenu.addEventListener('click', () => htmlClass.toggle('open'));
}

// dark theme
const metaTheme = document.querySelector('meta[name="theme-color"]');

function setTheme(isDark: boolean) {
  metaTheme?.setAttribute('content', isDark ? DARK_COLOR : LIGHT_COLOR);
  htmlClass[isDark ? 'add' : 'remove']('dark');
  localStorage.setItem('dark', `${isDark}`);
}

// init
const darkScheme = window.matchMedia('(prefers-color-scheme: dark)');
if (htmlClass.contains('dark')) {
  setTheme(true);
} else {
  const darkVal = localStorage.getItem('dark');
  setTheme(darkVal ? darkVal === 'true' : darkScheme.matches);
}

// listen system
darkScheme.addEventListener('change', (event) => setTheme(event.matches));

// manual switch
const btnDark = document.getElementById('button-dark');
if (btnDark) {
  btnDark.addEventListener('click', () => setTheme(!htmlClass.contains('dark')));
}
