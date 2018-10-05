# frozen_string_literal: true

module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, matches)
        save_assistance_experts_selection(diagnosis, matches[:assistances_experts])
        save_relays_selection(diagnosis, matches[:diagnosed_needs])
        diagnosis.contacted_persons.each do |person|
          ExpertMailer.delay.notify_company_needs(person, diagnosis)
        end
      end

      private

      def save_assistance_experts_selection(diagnosis, assistances_experts)
        assistance_expert_ids = ids_from_selected_checkboxes(assistances_experts)
        if assistance_expert_ids.empty?
          return
        end
        UseCases::CreateMatches.perform(diagnosis, assistance_expert_ids)
      end

      def save_relays_selection(diagnosis, diagnosed_needs)
        diagnosed_need_ids = ids_from_selected_checkboxes(diagnosed_needs)
        if diagnosed_need_ids.empty?
          return
        end
        relays = Relay.of_diagnosis_location(diagnosis)
        relays.each do |relay|
          UseCases::CreateSelectedRelays.perform(relay, diagnosed_need_ids)
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
