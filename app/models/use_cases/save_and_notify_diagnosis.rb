# frozen_string_literal: true

module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, matches)
        save_assistance_experts_selection_and_notify(diagnosis, matches[:assistances_experts])
        save_relays_selection_and_notify(diagnosis, matches[:diagnosed_needs])
      end

      private

      def save_assistance_experts_selection_and_notify(diagnosis, assistances_experts)
        assistance_expert_ids = ids_from_selected_checkboxes(assistances_experts)
        if assistance_expert_ids.empty?
          return
        end
        UseCases::CreateMatches.perform(diagnosis, assistance_expert_ids)
        ExpertMailersService.delay.send_assistances_email(advisor: diagnosis.visit.advisor,
                                                          diagnosis: diagnosis,
                                                          assistance_expert_ids: assistance_expert_ids)
      end

      def save_relays_selection_and_notify(diagnosis, diagnosed_needs)
        diagnosed_need_ids = ids_from_selected_checkboxes(diagnosed_needs)
        if diagnosed_need_ids.empty?
          return
        end
        relays = Relay.of_diagnosis_location(diagnosis)
        relays.each do |relay|
          UseCases::CreateSelectedRelays.perform(relay, diagnosed_need_ids)
          ExpertMailersService.delay.send_relay_assistances_email(relay: relay,
                                                                  diagnosed_need_ids: diagnosed_need_ids,
                                                                  advisor: diagnosis.visit.advisor,
                                                                  diagnosis: diagnosis)
        end
      end

      def ids_from_selected_checkboxes(hash)
        if !hash
          return []
        end
        hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
      end
    end
  end
end
