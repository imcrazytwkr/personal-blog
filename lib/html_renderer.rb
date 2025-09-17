# frozen_string_literal: true
require "redcarpet"

class CustomHtmlRenderer < Redcarpet::Render::HTML
  def block_code(code, lang)
    "<pre class=\"highlight language-#{lang}\"><code>#{::CGI.escapeHTML(code)}</code></pre>"
  end
end
