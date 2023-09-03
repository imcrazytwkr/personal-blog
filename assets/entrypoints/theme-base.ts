const THEME_KEY = 'dark';

const getCurrentTheme = () => {
  const rawValue = localStorage.getItem(THEME_KEY);
  if (rawValue) {
    return rawValue === 'true';
  }

  const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  localStorage.setItem(THEME_KEY, `${isDark}`);
  return isDark;
}

if (getCurrentTheme()) {
  document.querySelector('meta[name="theme-color"]')?.setAttribute('content', '#000000');
  document.documentElement.classList.add(THEME_KEY);
}
