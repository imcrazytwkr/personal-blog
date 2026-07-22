import type { APIContext } from 'astro';
import { getCollection, render } from 'astro:content';
import { experimental_AstroContainer } from 'astro/container';
import { getAtomString } from 'astrojs-atom';
import { SITE, AUTHOR } from '../constants';

export async function GET(context: APIContext) {
  // Newest first; take the 5 most recent (matches Middleman `blog.articles.take(5)`).
  const posts = (await getCollection('blog'))
    .sort((a, b) => b.data.date.getTime() - a.data.date.getTime())
    .slice(0, 5);

  const container = await experimental_AstroContainer.create();
  const entry = await Promise.all(
    posts.map(async (post) => {
      const url = new URL(`/post/${post.id}`, context.site).href;
      const { Content } = await render(post);
      const html = await container.renderToString(Content);
      return {
        title: post.data.title,
        id: url,
        published: post.data.date.toISOString(),
        // Original used File.mtime; we use the publish date (deterministic).
        updated: post.data.date.toISOString(),
        link: [{ href: url, rel: 'alternate', type: 'text/html' }],
        content: { value: html, type: 'html' },
      };
    }),
  );

  const xml = await getAtomString({
    title: SITE.title,
    id: SITE.absoluteUrl,
    updated: posts[0]?.data.date.toISOString() ?? new Date().toISOString(),
    author: [{ name: AUTHOR.name }],
    link: [
      { href: new URL('/feed.xml', context.site).href, rel: 'self', type: 'application/atom+xml' },
      { href: SITE.absoluteUrl, rel: 'alternate', type: 'text/html' },
    ],
    entry,
  });

  return new Response(xml, {
    headers: { 'Content-Type': 'application/atom+xml; charset=utf-8' },
  });
}
