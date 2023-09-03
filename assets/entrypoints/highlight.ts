import prism from 'prismjs';

import "prismjs/components/prism-bash"
import "prismjs/components/prism-json"
import "prismjs/components/prism-ruby"
import "prismjs/components/prism-yaml"

document.addEventListener("load", () => prism.highlightAll(true), {
  once: true,
  passive: true,
});
