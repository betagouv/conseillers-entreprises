class CompanyEmails::SolicitationsRelaunchJob < ApplicationJob
  queue_as :low_priority

  def perform
    solicitations = SolicitationsRelaunchService.new.find_not_completed_solicitations
    send_emails(solicitations)
  end

  private

  def send_emails(solicitations)
    solicitations.each do |solicitation|
      if solicitation.status_step_company?
        CompanyMailer.solicitation_relaunch_company(solicitation).deliver_later(queue: 'low_priority')
      elsif solicitation.status_step_description?
        CompanyMailer.solicitation_relaunch_description(solicitation).deliver_later(queue: 'low_priority')
      end
    end
  end
end
