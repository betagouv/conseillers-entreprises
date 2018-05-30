# frozen_string_literal: true

module UseCases
  class CreateSelectedRelays
    class << self
      def perform(relay, diagnosed_need_ids)
        diagnosed_need_ids.each do |diagnosed_need_id|
          SelectedAssistanceExpert.create relay: relay,
                                          diagnosed_need_id: diagnosed_need_id,
                                          expert_full_name: relay.user.full_name,
                                          expert_institution_name: relay.user.institution
        end
      end
    end
  end
end
