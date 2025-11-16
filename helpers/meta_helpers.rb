module MetaHelpers
  def site_title
    data.meta.dig(:site, :title) || "Middleman"
  end

  def page_title
    current_page.data.title || site_title
  end
end
