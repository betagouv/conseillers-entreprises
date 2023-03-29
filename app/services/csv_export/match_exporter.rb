module CsvExport
  class MatchExporter < BaseExporter
    def fields
      # /!\ les fields de MatchExporter et SolicitationExporter doivent correspondre pour garantir la cohérence du fichier
      {
        solicitation_created_at: -> { I18n.l(solicitation&.created_at, format: :admin) if solicitation.present? },
        solicitation_id: -> { solicitation&.id },
        solicitation_description: -> { solicitation&.description },
        solicitation_provenance_category: -> { I18n.t(solicitation.provenance_category, scope: %i(solicitation provenance_categories)) if solicitation&.provenance_category&.present? },
        solicitation_provenance_title: -> { solicitation&.provenance_title },
        solicitation_provenance_detail: -> { solicitation&.provenance_detail },
        solicitation_gclid: -> { solicitation&.gclid },
        landing_theme_title: -> { solicitation&.landing_theme&.title },
        landing_subject_title: -> { solicitation&.subject&.label },
        siret: -> { facility.siret },
        commune: -> { facility.commune },
        facility_regions: -> { facility_regions&.pluck(:name).uniq.join(", ") },
        company_name: -> { company&.name },
        company_categorie_juridique: -> { company.categorie_juridique },
        company_naf: -> { facility.naf_code },
        company_effectif: -> { Effectif::CodeEffectif.new(facility.code_effectif).intitule_effectif },
        inscrit_rcs: -> { company.inscrit_rcs ? I18n.t('boolean.text.true') : I18n.t('boolean.text.false') },
        inscrit_rm: -> { company.inscrit_rm ? I18n.t('boolean.text.true') : I18n.t('boolean.text.false') },
        solicitation_full_name: -> { solicitation&.full_name },
        solicitation_email: -> { solicitation&.email },
        solicitation_phone_number: -> { solicitation&.phone_number },
        solicitation_badges: -> { solicitation.badges.pluck(:title).join(', ') if solicitation&.badges&.any? },
        solicitation_status: -> { solicitation&.human_attribute_value(:status) },
        match_created_at:  -> { I18n.l(created_at, format: :admin) },
        need_id: -> { need&.id },
        advisor: :advisor,
        real_theme: :theme,
        real_subject: :subject,
        match_id: :id,
        expert_id: :expert_id,
        expert: :expert,
        expert_antenne: :expert_antenne,
        expert_institution: :expert_institution,
        match_status: -> { human_attribute_value(:status, context: :short) },
        match_taken_care_of_at: -> { I18n.l(taken_care_of_at, format: :admin) if taken_care_of_at.present? },
        match_closed_at: -> { I18n.l(closed_at, format: :admin) if closed_at.present? },
        need_status: -> { need.human_attribute_value(:status, context: :csv) },
        archived_at: -> { I18n.l(archived_at, format: :admin) if archived_at.present? },
        page_besoin: -> { Rails.application.routes.url_helpers.need_url(self.need) },
        satisfaction_contacted_by_expert: -> { I18n.t(company_satisfaction.contacted_by_expert, scope: [:boolean, :text]) if company_satisfaction&.present? },
        satisfaction_useful_exchange: -> { I18n.t(company_satisfaction.useful_exchange, scope: [:boolean, :text]) if company_satisfaction&.present? },
        satisfaction_comment: -> { company_satisfaction&.comment },
      }
    end

    def preloaded_associations
      [
        :need, :diagnosis, :facility, :company, :related_matches,
        :advisor, :expert, :expert_antenne, :expert_institution,
        :subject, :theme, :solicitation, :company_satisfaction,
        :facility_regions, solicitation: :badges,
        facility: :commune, diagnosis: :visitee,
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |m| [(m.solicitation&.created_at || m.created_at), m.created_at] }
    end
  end
end
