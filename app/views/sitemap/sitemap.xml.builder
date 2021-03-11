# Human-readable spec: https://www.sitemaps.org/fr/protocol.html
xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # Landing pages
  Landing.all.preload(:landing_options).each do |landing|
    xml.url do
      xml.loc landing_url(landing)
      xml.lastmod landing.updated_at.iso8601
      xml.changefreq 'weekly'
    end

    # And their options
    landing.landing_options.each do |landing_option|
      xml.url do
        xml.loc new_solicitation_landing_url(landing, landing_option)
        xml.lastmod landing.updated_at.iso8601
        xml.changefreq 'weekly'
      end
    end
  end

  # Misc static pages
  static_pages = [comment_ca_marche_url, public_index_url, ENV['BLOG_URL']]
  static_pages.each do |page|
    xml.url do
      xml.loc page
      xml.changefreq 'monthly'
    end
  end
end
