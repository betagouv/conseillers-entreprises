# frozen_string_literal: true

class SolicitationsRelaunchService
  def self.perform
    solicitations = find_not_completed_solicitations
    send_emails(solicitations)
  end

  def self.send_emails(solicitations)
    solicitations.each do |solicitation|
      CompanyMailer.solicitation_relaunch(solicitation).deliver_later
    end
  end

  def self.find_not_completed_solicitations
    to_relaunch = []
    Solicitation.step_incomplete.where(created_at: 2.days.ago..1.day.ago).each do |solicitation|
      if Solicitation.step_complete.from_same_company(solicitation).where(created_at: 2.days.ago..).empty?
        to_relaunch << solicitation
      end
    end
    to_relaunch
  end
end
