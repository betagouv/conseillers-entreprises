module UseCases
  class UpdateExpertViewedPageAt
    class << self
      def perform(diagnosis:, expert:)
        matches = diagnosis.matches
          .of_expert(expert)
          .not_viewed
        matches.update_all expert_viewed_page_at: Time.zone.now
      end
    end
  end
end
