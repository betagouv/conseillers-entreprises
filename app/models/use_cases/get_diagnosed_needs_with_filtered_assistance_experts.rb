# frozen_string_literal: true

module UseCases
  class GetDiagnosedNeedsWithFilteredAssistanceExperts
    class << self
      def of_diagnosis(diagnosis)
        associations = [question: [assistances: [assistances_experts: [expert: :institution]]]]
        diagnosed_needs = DiagnosedNeed.of_diagnosis(diagnosis).joins(associations).includes(associations)
        select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
      end

      private

      def select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
        all_assistances_experts_in_scope = AssistanceExpert.of_city_code(diagnosis.visit.location)
                                                           .of_naf_code(diagnosis.visit.facility.naf_code)
        diagnosed_needs.each do |diagnosed_need|
          diagnosed_need.question.assistances.each do |assistance|
            assistance.assistances_experts &= all_assistances_experts_in_scope
          end
        end
      end
    end
  end
end
