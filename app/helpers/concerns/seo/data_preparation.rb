module Seo
  module DataPreparation
    extend ActiveSupport::Concern

    # Méthodes de préparation des données pour les schémas SEO

    def prepare_themes_schema_items(landing_themes, landing_slug)
      landing_themes.map do |theme|
        {
          name: theme.meta_title.presence || theme.title,
          description: theme.meta_description.presence || theme.description,
          url: landing_theme_url(landing_slug: landing_slug, slug: theme.slug)
        }
      end
    end

    def prepare_subjects_schema_items(landing_subjects, landing_slug)
      landing_subjects.map do |subject|
        description = subject.meta_description.presence || subject.description
        title = I18n.t('landings.landings.seo.advisor_for', title: subject.meta_title.presence || subject.title)
        {
          name: title.capitalize,
          description: strip_tags(description&.gsub(/<\/li>\s*<li/, "</li>. <li"))&.squish,
          url: new_solicitation_url(landing_slug: landing_slug, landing_subject_slug: subject.slug)
        }
      end
    end

    def partner_organizations_schema(institutions: nil)
      # Si aucune liste d'institutions n'est fournie, utiliser tous les partenaires nationaux affichés sur la page d'accueil
      institutions_list = institutions || Institution.national.with_home_page_logo

      institutions_list.map do |institution|
        {
          '@type': "GovernmentOrganization",
          name: institution.name
        }
      end
    end

    def theme_partner_institutions(landing_theme)
      # Récupère toutes les institutions liées aux subjects de ce thème
      Institution
        .joins(institutions_subjects: { subject: :landing_subjects })
        .where(landing_subjects: { landing_theme_id: landing_theme.id })
        .with_solicitable_logo
        .distinct
        .order(:name)
    end
  end
end
