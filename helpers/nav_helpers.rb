# frozen_string_literal: true

module NavHelpers
  def internal_resource(path)
    internal_path = "#{path.delete_prefix('/')}.html"
    sitemap.resources.find do |resource|
      resource.path == internal_path
    end
  end
end
