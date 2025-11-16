xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  blog_url = absolute_url(blog.options.prefix.to_s)

  xml.title site_title

  xml.link href: absolute_url(current_page.path), rel: "self", type: "application/atom+xml"
  xml.link href: blog_url, rel: "alternate", type: "text/html"
  xml.id blog_url

  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author do
    xml.name data.meta.dig(:author, :name)
  end

  blog.articles.take(5).each do |article|
    article_url = absolute_url(article.url)
    xml.entry do
      xml.title article.title
      xml.link href: article_url, rel: "alternate", type: "text/html"
      xml.id article_url
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601

      xml.summary article.data.summary, type: html unless article.data.fetch(:summary, "").blank?
      xml.content article.body, type: "html"
    end
  end
end
