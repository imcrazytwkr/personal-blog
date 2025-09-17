# frozen_string_literal: true

require "vite_ruby"
require "vite_padrino/tag_helpers"

require_relative "lib/html_renderer"

# Making Middleman use RedCarpet with GHFM support and PrismJS code highlighting
# https://middlemanapp.com/advanced/template-engine-options/#markdown

set :markdown_engine, :redcarpet
set :markdown,
  renderer: CustomHtmlRenderer,
  space_after_headers: true,
  fenced_code_blocks: true,
  no_intra_emphasis: true,
  lax_html_blocks: true,
  strikethrough: true,
  superscript: true,
  tables: true

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :external_pipeline,
  name: :vite,
  command: "bin/vite #{build? ? :build : :dev}",
  source: ViteRuby.config.public_dir,
  latency: 1

activate :blog do |blog|
  blog.layout = "post"
  blog.default_extension = ".md"
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"

  blog.tag_template = "tag.html"

  blog.generate_day_pages = false
  blog.generate_month_pages = false
  blog.generate_year_pages = false

  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"

  blog.permalink = "post/{year}-{month}-{day}-{title}.html"
  blog.taglink = "tag/{tag}.html"
end

activate :directory_indexes

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false

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
