export const SITE = {
  title: '@twkr',
  rssEnabled: true,
  absoluteUrl: 'https://twkr.dev',
  languageCode: 'en',
} as const;

export const AUTHOR = {
  name: 'twkr',
  avatar: 'persica_coffee_avatar.webp',
} as const;

export const BIO = `A personal blog by ${AUTHOR.name}`;

export type SocialEntry = {
  url: string;
  icon: string;
  alt: string;
  wide?: boolean;
};

export const SOCIAL: SocialEntry[] = [
  { url: 'https://github.com/imcrazytwkr', icon: 'github.svg', alt: 'github' },
  { url: 'https://bitbucket.org/twkr/workspace/repositories', icon: 'bitbucket.svg', alt: 'bitbucket' },
  { url: 'https://linkedin.com/in/d-chernov', icon: 'linkedin.svg', alt: 'linkedin' },
  { url: 'https://hdev.im/@twkr', icon: 'mastodon.svg', alt: 'mastodon' },
];

export type MenuEntry = {
  name: string;
  url: string;
};

export const MENU: MenuEntry[] = [
  { name: 'About', url: '/about' },
];
