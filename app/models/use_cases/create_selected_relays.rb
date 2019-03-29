module UseCases
  class CreateSelectedRelays
    class << self
      def perform(relay, need_ids)
        need_ids.each do |need_id|
          Match.create relay: relay,
                       need_id: need_id,
                       expert_full_name: relay.user.full_name,
                       expert_institution_name: relay.user.institution
        end
      end
    end
  end
end
