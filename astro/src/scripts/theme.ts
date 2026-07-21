import { COLORS } from '../constants'

const CONTENT_KEY = 'content';
const THEME_KEY = 'dark';
const BG_TRANSPARENT = 'bg-transparent';
const BG_INHERIT = 'bg-inherit';

const htmlClass = document.documentElement.classList;

// Enable CSS transitions only after the first frame, so the no-FOUC `.dark`
// add done by the head script doesn't animate.
const init = () => htmlClass.remove('not-ready');
if (typeof requestIdleCallback === 'function') {
  requestIdleCallback(init, { timeout: 100 });
} else {
  setTimeout(init, 10);
}

// NOTE: `for...in` over a DOMTokenList enumerates indices, not class values,
// so this always falls through to `colors.linen`. Ported verbatim from the
// original theme.ts; flagged for review (would be `for...of` to read the
// actual bg-* class, e.g. wheat). See plans_migration.md §1.2.
function getCurrentLightColor() {
  for (const cn of htmlClass) {
    console.log(cn);
    if (!cn.startsWith('bg-')) {
      continue;
    }

    const color = COLORS[cn.slice(3)];
    if (color) {
      return color;
    }
  }

  return COLORS.linen;
}

const LIGHT_COLOR = getCurrentLightColor();
const DARK_COLOR = '#000000';

// Mobile menu
const btnMenu = document.getElementById('button-menu');
if (btnMenu) {
  btnMenu.addEventListener('click', () => htmlClass.toggle('open'), { passive: true });
}

// Dark theme
const metaTheme = document.querySelector('meta[name="theme-color"]');
const mainHeader = document.getElementById('main-header');

function setTheme(isDark: boolean) {
  localStorage.setItem(THEME_KEY, `${isDark}`);
  requestAnimationFrame(() => {
    metaTheme?.setAttribute(CONTENT_KEY, isDark ? DARK_COLOR : LIGHT_COLOR);
    mainHeader?.classList.replace(BG_INHERIT, BG_TRANSPARENT);
    htmlClass[isDark ? 'add' : 'remove'](THEME_KEY);
    setTimeout(
      () => requestAnimationFrame(() => mainHeader?.classList.replace(BG_TRANSPARENT, BG_INHERIT)),
      200,
    );
  });
}

if (!htmlClass.contains(THEME_KEY)) {
  metaTheme?.setAttribute(CONTENT_KEY, LIGHT_COLOR);
}

window
  .matchMedia('(prefers-color-scheme: dark)')
  .addEventListener('change', (event) => setTheme(event.matches), { passive: true });

document
  .getElementById('button-dark')
  ?.addEventListener('click', () => setTheme(!htmlClass.contains(THEME_KEY)), { passive: true });
