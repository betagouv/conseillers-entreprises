# frozen_string_literal: true

module UseCases
  class UpdateExpertViewedPageAt
    class << self
      def perform(diagnosis_id:, expert_id:)
        selected_assistances_experts = SelectedAssistanceExpert.of_diagnoses(diagnosis_id)
                                                               .of_expert(expert_id)
                                                               .not_viewed
        selected_assistances_experts.update_all expert_viewed_page_at: Time.zone.now
      end
    end
  end
end
