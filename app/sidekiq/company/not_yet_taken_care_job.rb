class Company::NotYetTakenCareJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'
  WAITING_TIME = 9.days

  def perform
    retrieve_solicitations.each do |solicitation|
      CompanyMailer.not_yet_taken_care(solicitation).deliver_later(queue: 'low_priority')
    end
  end

  private

  def retrieve_solicitations
    Solicitation.joins(diagnosis: :needs)
      .where(created_at: WAITING_TIME.ago.all_day,
                       diagnoses: { step: :completed, needs: { status: :quo } })
  end
end