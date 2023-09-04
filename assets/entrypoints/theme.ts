import colors from '../../config/colors.json';

const CONTENT_KEY = 'content';
const THEME_KEY = 'dark';

const BG_TRANSPARENT = 'bg-transparent';
const BG_INHERIT = 'bg-inherit';

// base
const htmlClass = document.documentElement.classList;

// Allow animations
const init = () => htmlClass.remove('not-ready');
if (typeof requestIdleCallback === 'function') {
  requestIdleCallback(init, { timeout: 100 });
} else {
  setTimeout(init, 10);
}

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
  btnMenu.addEventListener('click', () => htmlClass.toggle('open'), { passive: true });
}

// dark theme
const metaTheme = document.querySelector('meta[name="theme-color"]');
const mainHeader = document.getElementById('main-header');

function setTheme(isDark: boolean) {
  localStorage.setItem(THEME_KEY, `${isDark}`);
  requestAnimationFrame(() => {
    metaTheme?.setAttribute(CONTENT_KEY, isDark ? DARK_COLOR : LIGHT_COLOR);
    mainHeader?.classList.replace(BG_INHERIT, BG_TRANSPARENT);

    htmlClass[isDark ? 'add' : 'remove'](THEME_KEY);
    setTimeout(() => requestAnimationFrame(
      () => mainHeader?.classList.replace(BG_TRANSPARENT, BG_INHERIT)
    ), 200);
  });
}

// init
if (!htmlClass.contains(THEME_KEY)) {
  // No reason to wrap in RAF because this attributes is not tied to repaints
  metaTheme?.setAttribute(CONTENT_KEY, LIGHT_COLOR);
}

// listen system
window.matchMedia('(prefers-color-scheme: dark)')
  .addEventListener('change', (event) => setTheme(event.matches), { passive: true });

// manual switch
document.getElementById('button-dark')
  ?.addEventListener('click', () => setTheme(!htmlClass.contains(THEME_KEY)), { passive: true });
