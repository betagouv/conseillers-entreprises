module LLMGenerator
  def self.perform
    [header, landings_section, about_section, optional_section].join("\n\n") + "\n"
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
      lines << link_line(landing.title, helpers.landing_url(landing), landing.meta_description)
      # Filter the preloaded association in Ruby to avoid an N+1 query per landing.
      landing.landing_themes.select(&:not_archived?).each do |theme|
        lines << "  #{link_line(theme.title, helpers.landing_theme_url(landing, theme), theme.description)}"
      end
    end
    lines.join("\n")
  end

  # Pages that describe the service.
  # Regulatory pages (CGU, mentions légales, RGPD) are excluded.
  def self.about_section
    pages = [
      [I18n.t('about.comment_ca_marche.long_title'), helpers.comment_ca_marche_url],
      [I18n.t('about.equipe.title'), helpers.equipe_url],
      [I18n.t('about.temoignages_experts.title'), helpers.temoignages_experts_url]
    ]
    section('about', pages)
  end

  # Secondary pages (stats, accessibility, regulatory). "Optional" is a reserved
  # llms.txt section that tools may skip when a shorter context is needed.
  def self.optional_section
    pages = [
      [I18n.t('stats.public.index.title'), helpers.public_index_url],
      [I18n.t('about.accessibilite.title'), helpers.accessibilite_url],
      [I18n.t('about.mentions_legales.title'), helpers.mentions_legales_url],
      [I18n.t('about.mentions_d_information.title'), helpers.mentions_d_information_url],
      [I18n.t('cgu'), helpers.cgu_url]
    ]
    section('optional', pages)
  end

  def self.section(key, pages)
    lines = ["## #{I18n.t("llms.sections.#{key}")}"]
    pages.each { |title, url| lines << link_line(title, url) }
    lines.join("\n")
  end

  # Formats a markdown list item per the llms.txt spec: "- [title](url): description".
  # The description is optional and omitted (with its colon) when blank.
  def self.link_line(title, url, description = nil)
    description = description.to_s.squish
    item = "- [#{title.to_s.squish}](#{url})"
    description.present? ? "#{item}: #{description}" : item
  end

  def self.helpers
    Rails.application.routes.url_helpers
  end
end
