# frozen_string_literal: true

module UseCases
  class GetDiagnosedNeedsWithLocalizedAssistanceExperts
    class << self
      def of_diagnosis(diagnosis)
        associations = [question: [assistances: [assistances_experts: [expert: :institution]]]]
        diagnosed_needs = DiagnosedNeed.of_diagnosis(diagnosis).joins(associations).includes(associations)
        localized_assistances_experts = AssistanceExpert.of_city_code(diagnosis.visit.location).of_diagnosis(diagnosis)
        diagnosed_needs.each do |diagnosed_need|
          diagnosed_need.question.assistances.each do |assistance|
            assistance.assistances_experts &= localized_assistances_experts
          end
        end
      end
    end
  end
end
