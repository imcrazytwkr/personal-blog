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

  # Modified Middleman image_tag so that it finds the paths for srcset
  # in Vite manifest before passing them down to asset_path inside the
  # original image_tag helper
  def vite_image_tag(path, params={})
    params.symbolize_keys!

    if params.key?(:srcset)
      images_sources = params[:srcset].split(',')
      images_sources.map! do |src_def|
        if src_def.include? '//'
          src_def.strip
        else
          image_def, size_def = src_def.strip.split(/\s+/)
          "#{vite_asset_path(:images, image_def)} #{size_def}"
        end
      end

      params[:srcset] = images_sources.join(', ')
    end

    image_tag vite_asset_path(:images, path), params
  end
end
