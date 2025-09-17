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

  # A highly opinionated helper for scaled images. Initially written for
  # main index page as inlining it into ERB is a nightmare
  def vite_scaled_image_tag(path, params = {})
    params.symbolize_keys!

    max_scale = params.delete(:max_scale)

    # Don't be evil
    params.delete(:srcset)

    raise ArgumentError.new(
      "max_scale property is not defined for scaled image"
    ) if max_scale.nil?

    raise ArgumentError.new(
      "max_scale property must be an integer"
    ) unless max_scale.is_a? Integer

    raise ArgumentError.new(
      "max_scale has invalid value, must be at least 1"
    ) if max_scale < 1

    breadcrumbs = path.split(".")

    extname = breadcrumbs.pop
    basename = breadcrumbs.join(".")

    if max_scale > 1
      # While I could reuse the logic from vite_image_tag here, this
      # implementation leaves the asset path mapping in a single place
      # which simplifies maintenance
      sources = (1..max_scale).map do |i|
        "#{basename}_x#{i}.#{extname} #{i}x"
      end

      params[:srcset] = sources.join(", ")
    end

    vite_image_tag("#{basename}_x1.#{extname}", params)
  end

  # Modified Middleman image_tag so that it finds the paths for srcset
  # in Vite manifest before passing them down to asset_path inside the
  # original image_tag helper
  def vite_image_tag(path, params = {})
    params.symbolize_keys!

    if params.key?(:srcset)
      images_sources = params[:srcset].split(",")
      images_sources.map! do |src_def|
        if src_def.include? "//"
          src_def.strip
        else
          image_def, size_def = src_def.strip.split(/\s+/, 2)

          # @TODO: remove explicit scale append when fixed in middleman
          #
          # Explicitly appending the implicit "1x" scale value is necessary,
          # because otherwise Middleman's `asset_path`` helper crashes even
          # though such syntax is valid
          "#{vite_asset_path(:images, image_def)} #{size_def || "1x"}"
        end
      end

      params[:srcset] = images_sources.join(", ")
    end

    image_tag vite_asset_path(:images, path), params
  end

  def vite_inline_typescript(name, **options)
    vite_inline_javascript! name, :ts, asset_type: :typescript, **options
  end

  def vite_inline_javascript(name, **options)
    vite_inline_javascript! name, :js, **options
  end

  private

  def vite_inline_javascript!(name, ext, **options)
    if @app.build?
      path = ViteRuby.config.public_dir + vite_asset_path(:js, "#{name}.#{ext.to_s}")
      "<script type=\"text/javascript\">#{File.read(path).strip}</script>"
    else
      vite_javascript_tag "theme-base", **options, type: "text/javascript"
    end
  end
end
