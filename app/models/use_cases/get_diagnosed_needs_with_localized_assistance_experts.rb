# frozen_string_literal: true

module UseCases
  class GetDiagnosedNeedsWithLocalizedAssistanceExperts
    class << self
      def of_diagnosis(diagnosis)
        territories = Territory.joins(:territory_cities)
                        .where(territory_cities: { city_code: diagnosis.visit.location })
        associations = [question: [assistances: [assistances_experts: [expert: :institution]]]]
        query = { question:
                    { assistances_experts:
                        { expert:
                            { expert_territories: { territory_id: territories.map(&:id) } }
                        }
                    }
        }

          DiagnosedNeed.of_diagnosis(diagnosis)
            .includes(associations)
            .where(query)
            .references(associations)
      end
    end
  end
end