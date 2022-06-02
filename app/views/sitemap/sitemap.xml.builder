# Human-readable spec: https://www.sitemaps.org/fr/protocol.html
xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # Landing pages
  Landing.locales.preload(:landing_themes).each do |landing|
    xml.url do
      xml.loc landing_url(landing)
      xml.lastmod landing.updated_at.iso8601
      xml.changefreq 'weekly'
    end

    landing.landing_themes.preload(:landing_subjects).each do |landing_theme|
      xml.url do
        xml.loc landing_theme_url(landing, landing_theme)
        xml.lastmod landing_theme.updated_at.iso8601
        xml.changefreq 'weekly'
      end

      landing_theme.landing_subjects.each do |landing_subject|
        xml.url do
          xml.loc new_solicitation_path(landing.slug, landing_subject.slug)
          xml.lastmod landing_subject.updated_at.iso8601
          xml.changefreq 'weekly'
        end
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
