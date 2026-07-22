// Faithful port of Middleman's html_renderer.rb `image` callback, which
// repurposed the markdown image `title` attribute as a CSS class:
//   ![alt](src "max-w-full mx-auto")  ->  <img class="max-w-full mx-auto" ...>
// Standard markdown would otherwise render that title verbatim as a tooltip.
export default function rehypeImageClass() {
  const walk = (node) => {
    if (
      node.type === "element" &&
      node.tagName === "img" &&
      node.properties &&
      node.properties.title
    ) {
      node.properties.className = [String(node.properties.title)];
      delete node.properties.title;
    }
    if (node.children) {
      for (const child of node.children) walk(child);
    }
  };
  return (tree) => walk(tree);
}
