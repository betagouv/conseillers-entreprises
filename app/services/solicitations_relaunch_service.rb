# frozen_string_literal: true

class SolicitationsRelaunchService
  def self.find_not_completed_solicitations
    to_relaunch = []
    Solicitation.step_incomplete.where(created_at: 2.days.ago..1.day.ago).each do |solicitation|
      if Solicitation.step_complete.from_same_company(solicitation).where(created_at: 2.days.ago..).empty?
        to_relaunch << solicitation
      end
    end
    to_relaunch.uniq
  end
end
