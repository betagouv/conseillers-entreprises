# frozen_string_literal: true

module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, selected_assistances_experts)
        save_assistance_experts_selection_and_notify diagnosis, selected_assistances_experts[:assistances_experts]
        save_territory_users_selection_and_notify diagnosis,
                                                  selected_assistances_experts[:diagnosed_needs]
      end

      private

      def save_assistance_experts_selection_and_notify(diagnosis, assistances_experts)
        assistance_expert_ids = ids_from_selected_checkboxes(assistances_experts)
        return if assistance_expert_ids.empty?
        UseCases::CreateSelectedAssistancesExperts.perform(diagnosis, assistance_expert_ids)
        ExpertMailersService.delay.send_assistances_email(advisor: diagnosis.visit.advisor,
                                                          diagnosis: diagnosis,
                                                          assistance_expert_ids: assistance_expert_ids)
      end

      def save_territory_users_selection_and_notify(diagnosis, diagnosed_needs)
        diagnosed_need_ids = ids_from_selected_checkboxes(diagnosed_needs)
        return if diagnosed_need_ids.empty?
        territory_user = TerritoryUser.of_diagnosis_location(diagnosis).first
        UseCases::CreateSelectedTerritoryUsers.perform(territory_user, diagnosed_need_ids)
        ExpertMailersService.delay.send_territory_user_assistances_email(territory_user: territory_user,
                                                                         diagnosed_need_ids: diagnosed_need_ids,
                                                                         advisor: diagnosis.visit.advisor,
                                                                         diagnosis: diagnosis)
      end

      def ids_from_selected_checkboxes(hash)
        hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
      end
    end
  end
end
