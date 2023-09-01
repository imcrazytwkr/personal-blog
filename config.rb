# frozen_string_literal: true

require "vite_ruby"
require "vite_padrino/tag_helpers"

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers

helpers VitePadrino::TagHelpers

# Development-sprcific configuration

configure :development do
  use ViteRuby::DevServerProxy, ssl_verify_none: true
end

# Build-specific configuration

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
