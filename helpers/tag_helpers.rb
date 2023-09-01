# frozen_string_literal: true

# Makes VitePadrino Tag Helpers compatible with underlying middleman ones
module TagHelpers
  # Public: Resolves the path for the specified Vite asset.
  #
  # Example:
  #   <%= vite_asset_path :css, 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(kind, name, **options)
    asset_path kind, vite_manifest.path_for(name, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet_tag(*names, **options)
    style_paths = names.map { |name| vite_asset_path(:css, name, type: :stylesheet) }
    stylesheet_link_tag(*style_paths, **options)
  end
end
