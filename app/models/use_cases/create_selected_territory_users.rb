# frozen_string_literal: true

module UseCases
  class CreateSelectedTerritoryUsers
    class << self
      def perform(territory_user, diagnosed_needs)
        diagnosed_needs.each do |diagnosed_need|
          SelectedAssistanceExpert.create territory_user: territory_user,
                                          diagnosed_need: diagnosed_need,
                                          expert_full_name: territory_user.user.full_name,
                                          expert_institution_name: territory_user.user.institution
        end
      end
    end
  end
end
