# frozen_string_literal: true

class SolicitationsRelaunchService
  def initialize
    @solicitations_to_relaunch = []
  end

  def find_not_completed_solicitations
    Solicitation.step_incomplete.where(created_at: 2.days.ago..1.day.ago).find_each do |solicitation|
      if Solicitation.step_complete.from_same_company(solicitation).where(created_at: 2.days.ago..).empty?
        @solicitations_to_relaunch << solicitation
      end
    end
    @solicitations_to_relaunch
  end
end
