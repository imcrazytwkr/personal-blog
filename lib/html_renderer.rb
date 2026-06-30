# frozen_string_literal: true
require "redcarpet"

class CustomHtmlRenderer < Redcarpet::Render::HTML
  cattr_accessor :scope

  def block_code(code, lang)
    "<pre class=\"highlight language-#{lang}\"><code>#{::CGI.escapeHTML(code)}</code></pre>"
  end

  def header(title, level)
    raise ArgumentError.new(
      "<h#{level}>#{title}</h#{level}>"
    ) unless level.between? 1, 5

    return super(title, level) if level > 3

    "<h#{level} id=\"#{title.parameterize}\">#{title}</h#{level}>"
  end

  ABSOLUTE_URL_RE = /^(?:[a-z+]+:)?\/\//i

  def link(link, title, content)
    raise ArgumentError.new(
      "Link titles are not supported!"
    ) unless title.blank?

    if scope.respond_to? :link_to
      params = {}
      params[:rel] = "noopener noreferrer" if ABSOLUTE_URL_RE.match? link

      return scope.link_to(content, title, params)
    end

    params = String.new
    params << " href=\"#{link.strip}\""
    params << ' rel="noopener noreferrer"' if ABSOLUTE_URL_RE.match? link
    return "<a#{params}>#{content}</a>"
  end

  def image(link, classname, alt)
    # `super` keyword works weidly with if/unless
    return super(link, classname, alt) unless scope.respond_to? :vite_image_tag

    params = {}
    params[:class] = classname.strip unless classname.blank?
    params[:alt] = alt.strip unless alt.blank?
    return scope.vite_image_tag(link, params)
  end
end
