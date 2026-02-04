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
    ) unless title.nil? or title.blank?

    # @TODO: uncomment when 4.6.3 releases
    # params = {}
    # params[:rel] = "noopener noreferrer" if ABSOLUTE_URL_RE.match? link
    #
    # return scope.link_to(content, title, params)

    params = String.new
    params << " href=\"#{link.strip}\""
    params << ' rel="noopener noreferrer"' if ABSOLUTE_URL_RE.match? link
    "<a#{params}>#{content}</a>"
  end

  # @TODO: uncomment when 4.6.3 releases
  #
  # def image(link, classname, alt)
  #   params = {}
  #   params[:class] = classname.strip unless classname.nil? or classname.blank?
  #   params[:alt] = alt.strip
  #   return scope.vite_image_tag(link, params)
  # end

end
