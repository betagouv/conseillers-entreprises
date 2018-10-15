# frozen_string_literal: true

module UseCases
  class GetDiagnosedNeedsWithFilteredAssistanceExperts
    class << self
      def of_diagnosis(diagnosis)
        inclusions = [question: [assistances: [assistances_experts: [expert: :local_office]]]]
        diagnosed_needs = DiagnosedNeed.of_diagnosis(diagnosis).includes(inclusions)
        diagnosed_needs = diagnosed_needs.order('questions.category_id, questions.id')
        select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
      end

      private

      def select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
        all_assistances_experts_in_scope = AssistanceExpert.of_city_code(diagnosis.visit.facility.city_code)
          .of_naf_code(diagnosis.visit.facility.naf_code)
        diagnosed_needs.each do |diagnosed_need|
          question = diagnosed_need.question # the underlying question might have been deleted by admins
          if question.present?
            diagnosed_need.question.assistances.each do |assistance|
              assistance.filtered_assistances_experts = assistance.assistances_experts & all_assistances_experts_in_scope
            end
          end
        end
      end
    end
  end
end
