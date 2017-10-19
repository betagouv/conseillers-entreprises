# frozen_string_literal: true

module UseCases
  class CreateSelectedTerritoryUsers
    class << self
      def perform(territory_user, diagnosed_need_ids)
        diagnosed_need_ids.each do |diagnosed_need_id|
          SelectedAssistanceExpert.create territory_user: territory_user,
                                          diagnosed_need_id: diagnosed_need_id,
                                          expert_full_name: territory_user.user.full_name,
                                          expert_institution_name: territory_user.user.institution
        end
      end
    end
  end
end
