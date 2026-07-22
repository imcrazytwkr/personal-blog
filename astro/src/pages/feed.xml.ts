import type { APIContext } from "astro";
import { getCollection } from "astro:content";
import atom from "astrojs-atom";
import { SITE, AUTHOR } from "../constants";

const maxDate = (a: Date, b: Date) => (a.getTime() > b.getTime() ? a : b);

export async function GET(context: APIContext) {
  // Newest first; take the 5 most recent (matches Middleman `blog.articles.take(5)`).
  const posts = (await getCollection("blog"))
    .sort((a, b) => b.data.date.getTime() - a.data.date.getTime())
    .slice(0, 5);

  const entry = posts.map((post) => {
    const url = new URL(`/post/${post.id}/`, context.site).href;
    const html = post.rendered?.html;
    if (!html) {
      throw new TypeError(`Markdown for post ${post.id} is not rendered!`);
    }

    return {
      title: post.data.title,
      id: url,
      published: post.data.date.toISOString(),
      updated: (post.data.updated ?? post.data.date).toISOString(),
      link: [{ href: url, rel: "alternate", type: "text/html" }],
      content: { value: html, type: "html" },
    };
  });

  const updated = posts
    .reduce(
      (acc, post) =>
        maxDate(
          acc,
          post.data.updated
            ? maxDate(post.data.updated, post.data.date)
            : post.data.date,
        ),
      new Date(0),
    )
    .toISOString();

  return atom({
    title: SITE.title,
    id: context.site?.origin ?? SITE.absoluteUrl,
    updated,
    author: [
      {
        name: AUTHOR.name,
        uri: context.site?.origin,
      },
    ],
    link: [
      {
        href: new URL("/feed.xml", context.site).href,
        rel: "self",
        type: "application/atom+xml",
      },
      {
        href: new URL("/", context.site).href,
        rel: "alternate",
        type: "text/html",
      },
    ],
    entry,
  });
}
