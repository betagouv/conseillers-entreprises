class Company::SolicitationsRelaunchJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    solicitations = find_not_completed_solicitations
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

  def find_not_completed_solicitations
    to_relaunch = []
    Solicitation.step_incomplete.where(created_at: 2.days.ago..1.day.ago).find_each do |solicitation|
      if Solicitation.step_complete.from_same_company(solicitation).where(created_at: 2.days.ago..).empty?
        to_relaunch << solicitation
      end
    end
    to_relaunch
  end
end
