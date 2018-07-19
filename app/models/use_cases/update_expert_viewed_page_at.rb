# frozen_string_literal: true

module UseCases
  class UpdateExpertViewedPageAt
    class << self
      def perform(diagnosis_id:, expert_id:)
        matches = Match.of_diagnoses(diagnosis_id)
          .of_relay_or_expert(expert_id)
          .not_viewed
        matches.update_all expert_viewed_page_at: Time.zone.now
      end
    end
  end
end
