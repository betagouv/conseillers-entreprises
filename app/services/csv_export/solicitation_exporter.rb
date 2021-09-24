module CsvExport
  class SolicitationExporter < BaseExporter
    def fields
      {
        solicitation_id: -> { id },
        solicitation_created_at: -> { created_at },
        solicitation_description: -> { description },
        landing_subject_slug: -> { landing_subject&.slug },
        siret: -> { siret },
        commune: -> { diagnosis&.facility&.commune },
        facility_regions: -> { region&.name },
        company_name: -> { diagnosis&.company&.name },
        solicitation_full_name: -> { full_name },
        solicitation_email: -> { email },
        solicitation_phone_number: -> { phone_number },
        solicitation_badges: -> { badges.pluck(:title).join(', ') if badges&.any? },
        solicitation_status: -> { human_attribute_value(:status) },
        solicitation_provenance_category: -> { I18n.t(provenance_category, scope: %i(solicitation provenance_categories)) if provenance_category&.present? },
        solicitation_provenance_title: -> { provenance_title },
        solicitation_provenance_detail: -> { provenance_detail },
        solicitation_gclid: -> { gclid },
        diagnosis_id: -> { diagnosis&.id },
        diagnosis_created_at:  -> { diagnosis&.created_at },
      }
    end

    def preloaded_associations
      [
        :diagnosis, :facility, :badges, diagnosis: :company, facility: :commune
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |m| m.created_at }
    end
  end
end
