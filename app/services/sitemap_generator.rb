module SitemapGenerator
  def self.perform
    @content = []

    # Landing pages
    landings = Landing.intern.not_archived.preload(:landing_themes)

    # Pour afficher en premier la landing 'accueil'
    landings.where(slug: 'accueil').find_each do |landing|
      create_landing_hash(landing)
    end
    landings.where.not(slug: 'accueil').find_each do |landing|
      create_landing_hash(landing)
    end

    # Misc static pages
    static_pages = [
      { url: Rails.application.routes.url_helpers.comment_ca_marche_url, title: I18n.t('about.comment_ca_marche.title') },
      { url: Rails.application.routes.url_helpers.public_index_url, title: I18n.t('usage_stats') },
      { url: Rails.application.routes.url_helpers.accessibilite_url, title: I18n.t('about.accessibilite.title') },
      { url: Rails.application.routes.url_helpers.mentions_legales_url, title: I18n.t('about.mentions_legales.title') },
      { url: Rails.application.routes.url_helpers.mentions_d_information_url, title: I18n.t('about.mentions_d_information.title') },
      { url: Rails.application.routes.url_helpers.cgu_url, title: I18n.t('cgu') },
      { url: ENV['BLOG_URL'], title: I18n.t('about.blog.title') },
    ]
    static_pages.each_with_index do |page, idx|
      page_elt = {
        loc: page[:url],
        priority: 0.5,
        title: page[:title],
        href: true,
        changefreq: 'monthly',
        level: 1
      }
      @content << { "page_#{idx}": page_elt }
    end

    @content
  end

  def self.create_landing_hash(landing)
    landing_elt = {
      loc: Rails.application.routes.url_helpers.landing_url(landing),
      priority: 0.9,
      lasmod: landing.updated_at.iso8601,
      title: I18n.t(landing.slug, scope: 'sitemap', default: landing.title),
      href: true,
      changefreq: 'weekly',
      level: 1,
      elements: []
    }

    landing.landing_themes.not_archived.preload(:landing_subjects).find_each do |landing_theme|
      landing_theme_elt = {
        loc: Rails.application.routes.url_helpers.landing_theme_url(landing, landing_theme),
        priority: 0.7,
        lasmod: landing_theme.updated_at.iso8601,
        title: landing_theme.title,
        href: true,
        changefreq: 'weekly',
        level: 2,
        elements: []
      }

      landing_theme.landing_subjects.not_archived.each do |landing_subject|
        landing_subject_elt = {
          loc: Rails.application.routes.url_helpers.new_solicitation_url(landing.slug, landing_subject.slug),
          priority: 0.7,
          lasmod: landing_subject.updated_at.iso8601,
          title: landing_subject.title,
          href: true,
          changefreq: 'weekly',
          level: 3
        }
        landing_theme_elt[:elements] << { child_page: landing_subject_elt }
      end
      landing_elt[:elements] << { child_page: landing_theme_elt }
    end
    @content << { "#{landing.slug}": landing_elt }
  end
end
