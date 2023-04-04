class NotYetSupportedEmailService
  WAITING_TIME = 9.days

  def call
    retrieve_solicitations.each do |solicitation|
      CompanyMailer.not_yet_supported(solicitation).deliver_later
    end
  end

  private

  def retrieve_solicitations
    Solicitation.joins(diagnosis: :needs)
      .where(created_at: WAITING_TIME.ago.all_day,
             diagnoses: { step: :completed, needs: { status: :quo } })
  end
end
