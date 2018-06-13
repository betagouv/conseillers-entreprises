# frozen_string_literal: true

class ExpertReminderService
  attr_accessor :experts_hash

  class << self
    def send_reminders
      @experts_hash = {}
      matches_needing_taking_care_update
      matches_with_no_one_in_charge
      @experts_hash.each_value do |expert|
        ExpertMailer.delay.remind_involvement(expert[:expert], expert[:matches_hash])
      end
    end

    private

    def matches_needing_taking_care_update
      Match.includes(assistance_expert: :expert).needing_taking_care_update.each do |sae|
        if !sae.assistance_expert
          next
        end

        expert_id = sae.assistance_expert.expert_id

        if !@experts_hash[expert_id]
          init_expert_hash(sae)
        end
        @experts_hash[expert_id][:matches_hash][:needing_taking_care_update] << sae
      end
    end

    def matches_with_no_one_in_charge
      Match.includes(assistance_expert: :expert).with_no_one_in_charge.each do |sae|
        if !sae.assistance_expert
          next
        end

        expert_id = sae.assistance_expert.expert_id

        if !@experts_hash[expert_id]
          init_expert_hash(sae)
        end
        @experts_hash[expert_id][:matches_hash][:with_no_one_in_charge] << sae
      end
    end

    def init_expert_hash(match)
      expert = match.assistance_expert.expert
      @experts_hash[expert.id] = {
        expert: expert,
        matches_hash: {
          needing_taking_care_update: [],
          with_no_one_in_charge: []
        }
      }
    end
  end
end
