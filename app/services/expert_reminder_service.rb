# frozen_string_literal: true

class ExpertReminderService
  attr_accessor :experts_hash

  class << self
    def send_reminders
      @experts_hash = {}
      selected_assistances_experts_needing_taking_care_update
      selected_assistances_experts_with_no_one_in_charge
      @experts_hash.each_value do |expert|
        ExpertMailer.delay.remind_involvement(expert[:expert], expert[:selected_assistances_experts_hash])
      end
    end

    private

    def selected_assistances_experts_needing_taking_care_update
      SelectedAssistanceExpert.includes(assistance_expert: :expert).needing_taking_care_update.each do |sae|
        next unless sae.assistance_expert
        expert_id = sae.assistance_expert.expert_id
        init_expert_hash(sae) unless @experts_hash[expert_id]
        @experts_hash[expert_id][:selected_assistances_experts_hash][:needing_taking_care_update] << sae
      end
    end

    def selected_assistances_experts_with_no_one_in_charge
      SelectedAssistanceExpert.includes(assistance_expert: :expert).with_no_one_in_charge.each do |sae|
        next unless sae.assistance_expert
        expert_id = sae.assistance_expert.expert_id
        init_expert_hash(sae) unless @experts_hash[expert_id]
        @experts_hash[expert_id][:selected_assistances_experts_hash][:with_noone_in_charge] << sae
      end
    end

    def init_expert_hash(selected_assistance_expert)
      expert = selected_assistance_expert.assistance_expert.expert
      @experts_hash[expert.id] = {
        expert: expert,
        selected_assistances_experts_hash: {
          needing_taking_care_update: [],
          with_noone_in_charge: []
        }
      }
    end
  end
end
