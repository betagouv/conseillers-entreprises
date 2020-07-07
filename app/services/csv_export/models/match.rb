module CsvExport
  module Models
    module Match
      extend ActiveSupport::Concern
      class_methods do
        def csv_fields
          {
            id: :id,
            need: :need_id,
            company: :company,
            siret: -> { facility.siret },
            commune: -> { facility.commune },
            created_at: :created_at,
            advisor: :advisor,
            advisor_antenne: :advisor_antenne,
            advisor_institution: :advisor_institution,
            theme: :theme,
            subject: :subject,
            content: -> { need.content },
            expert: :expert,
            expert_antenne: :expert_antenne,
            expert_institution: :expert_institution,
            status: -> { need.human_attribute_value(:status, context: :short) },
            taken_care_of_at: :taken_care_of_at,
            closed_at: :closed_at,
            page_analyse: :need_url_route
          }
        end

        def csv_included_associations
          [
            :need, :diagnosis, :facility, :company, :related_matches,
            :advisor, :advisor_antenne, :advisor_institution,
            :expert, :expert_antenne, :expert_institution,
            :subject, :theme,
            facility: :commune
          ]
        end
      end

      def need_url_route
        Rails.application.routes.url_helpers.need_url(self.diagnosis)
      end
    end
  end
end
