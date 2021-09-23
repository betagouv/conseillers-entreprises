module CsvExport
  class MatchExporter < BaseExporter
    def fields
      {
        solicitation_created_at: -> { solicitation&.created_at },
        solicitation_id: -> { solicitation&.id },
        solicitation_description: -> { solicitation&.description },
        landing_subject_slug: -> { solicitation&.landing_subject&.slug },
        siret: -> { facility.siret },
        commune: -> { facility.commune },
        facility_regions: -> { facility_regions&.pluck(:name).uniq.join(", ") },
        company_name: -> { company&.name },
        company_naf: -> { facility.naf_libelle },
        company_effectif: -> { Effectif.effectif(facility.code_effectif) },
        solicitation_full_name: -> { solicitation&.full_name },
        solicitation_email: -> { solicitation&.email },
        solicitation_phone_number: -> { solicitation&.phone_number },
        solicitation_badges: -> { solicitation.badges.pluck(:title).join(', ') if solicitation&.badges&.any? },
        solicitation_status: -> { solicitation&.human_attribute_value(:status) },
        match_created_at: :created_at,
        solicitation_provenance_category: -> { I18n.t(solicitation.provenance_category, scope: %i(solicitation provenance_categories)) if solicitation&.provenance_category&.present? },
        solicitation_provenance_title: -> { solicitation&.provenance_title },
        solicitation_provenance_detail: -> { solicitation&.provenance_detail },
        solicitation_gclid: -> { solicitation&.gclid },
        advisor: :advisor,
        theme: :theme,
        subject: :subject,
        match_id: :id,
        expert: :expert,
        expert_antenne: :expert_antenne,
        expert_institution: :expert_institution,
        match_status: -> { human_attribute_value(:status, context: :short) },
        taken_care_of_at: :taken_care_of_at,
        need_status: -> { need.human_attribute_value(:status, context: :csv) },
        closed_at: :closed_at,
        archived_at: :archived_at,
        page_besoin: -> { Rails.application.routes.url_helpers.need_url(self.need) },
        satisfaction_contacted_by_expert: -> { I18n.t(company_satisfaction.contacted_by_expert, scope: [:boolean, :text]) if company_satisfaction&.present? },
        satisfaction_useful_exchange: -> { I18n.t(company_satisfaction.useful_exchange, scope: [:boolean, :text]) if company_satisfaction&.present? },
        satisfaction_comment: -> { company_satisfaction&.comment },
      }
    end

    def preloaded_associations
      [
        :need, :diagnosis, :facility, :company, :related_matches,
        :advisor, :advisor_antenne, :advisor_institution,
        :expert, :expert_antenne, :expert_institution,
        :subject, :theme,
        facility: :commune,
        diagnosis: :visitee,
      ]
    end
  end
end
