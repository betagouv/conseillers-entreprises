module CsvExport
  class MatchExporter < BaseExporter
    def fields
      {
        id: :id,
        need: :need_id,
        company: :company,
        visitee: -> { diagnosis.visitee&.email },
        siret: -> { facility.siret },
        commune: -> { facility.commune },
        facility_regions: -> { facility_regions&.pluck(:name).uniq.join(", ") },
        created_at: :created_at,
        advisor: :advisor,
        advisor_antenne: :advisor_antenne,
        advisor_institution: :advisor_institution,
        theme: :theme,
        subject: :subject,
        content: -> do
          if diagnosis.content.present? && need.content.present?
            "#{diagnosis.content} / #{need.content}"
          else
            diagnosis.content.presence || need.content.presence
          end
        end,
        expert: :expert,
        expert_antenne: :expert_antenne,
        expert_institution: :expert_institution,
        status: -> { human_attribute_value(:status, context: :short) },
        need_status: -> { need.human_attribute_value(:status, context: :short) },
        taken_care_of_at: :taken_care_of_at,
        closed_at: :closed_at,
        page_besoin: -> { Rails.application.routes.url_helpers.need_url(self.need) },
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
