# frozen_string_literal: true

module NavHelpers
  def site_url
    data.meta.dig(:site, :absolute_url) || "http://localhost"
  end

  def absolute_url(relative_url)
    URI.join(site_url, relative_url).to_s
  end

  def internal_resource(path)
    internal_path = "#{path.delete_prefix("/")}.html"
    sitemap.resources.find do |resource|
      resource.path == internal_path
    end
  end
end
