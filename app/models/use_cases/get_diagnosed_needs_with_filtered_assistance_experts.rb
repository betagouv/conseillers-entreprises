module UseCases
  class GetDiagnosedNeedsWithFilteredAssistanceExperts
    class << self
      def of_diagnosis(diagnosis)
        inclusions = [question: [assistances: [assistances_experts: [expert: :antenne_institution]]]]
        diagnosed_needs = diagnosis.diagnosed_needs.includes(inclusions)
        diagnosed_needs = diagnosed_needs.ordered_for_interview
        select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
      end

      private

      def select_localized_and_business_assistance_experts(diagnosed_needs, diagnosis)
        experts_in_scope = diagnosis.facility.commune.all_experts.of_naf_code(diagnosis.facility.naf_code)
        all_assistances_experts_in_scope = experts_in_scope.flat_map(&:assistances_experts)
        diagnosed_needs.each do |diagnosed_need|
          diagnosed_need.question.assistances.each do |assistance|
            assistance.filtered_assistances_experts = assistance.assistances_experts & all_assistances_experts_in_scope
          end
        end
      end
    end
  end
end
