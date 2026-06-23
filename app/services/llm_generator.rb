module LLMGenerator
  def self.perform
    [header, landings_section, about_section].join("\n\n") + "\n"
  end

  def self.header
    name = I18n.t('landings.landings.seo.service_name')
    summary = I18n.t('landings.landings.seo.service_description')
    how_it_works = I18n.t('landings.landings.seo.service_how_it_works')
    "# #{name}\n\n> #{summary}\n\n#{how_it_works}"
  end

  def self.landings_section
    lines = ["## #{I18n.t('llms.sections.landings')}"]
    Landing.ordered_for_indexing.each do |landing|
      lines << "- [#{landing.title}](#{helpers.landing_url(landing)})"
      # Filter the preloaded association in Ruby to avoid an N+1 query per landing.
      landing.landing_themes.select(&:not_archived?).each do |theme|
        lines << "  - [#{theme.title}](#{helpers.landing_theme_url(landing, theme)})"
      end
    end
    lines.join("\n")
  end

  # Pages that describe the service.
  # Regulatory pages (CGU, mentions légales, RGPD) are excluded, except accessibilité.
  def self.about_section
    pages = [
      [I18n.t('about.comment_ca_marche.long_title'), helpers.comment_ca_marche_url],
      [I18n.t('about.equipe.title'), helpers.equipe_url],
      [I18n.t('about.temoignages_experts.title'), helpers.temoignages_experts_url],
      [I18n.t('stats.public.index.title'), helpers.public_index_url],
      [I18n.t('about.accessibilite.title'), helpers.accessibilite_url]
    ]
    lines = ["## #{I18n.t('llms.sections.about')}"]
    pages.each { |title, url| lines << "- [#{title}](#{url})" }
    lines.join("\n")
  end

  def self.helpers
    Rails.application.routes.url_helpers
  end
end
