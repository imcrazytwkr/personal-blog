import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";
import { unified } from "@astrojs/markdown-remark";
import rehypeSlug from "rehype-slug";
import rehypeExternalLinks from "rehype-external-links";
import rehypeImageClass from "./src/plugins/rehype-image-class.js";

// https://astro.build/config
export default defineConfig({
  site: "https://twkr.dev",
  markdown: {
    // Build-time highlighting via @astrojs/prism (no client-side Prism JS).
    // Code blocks reuse prism-vsc-dark-plus.css (imported in Post.astro).
    syntaxHighlight: "prism",
    // Astro 7: plugins live on the processor via unified({...}), not on markdown.*.
    processor: unified({
      rehypePlugins: [
        rehypeSlug,
        // Match html_renderer.rb: rel only on absolute scheme:// links (no mailto, no target).
        [
          rehypeExternalLinks,
          { rel: "noopener noreferrer", protocols: ["http", "https"] },
        ],
        // Port of html_renderer.rb image(): title attr -> class.
        rehypeImageClass,
      ],
    }),
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
