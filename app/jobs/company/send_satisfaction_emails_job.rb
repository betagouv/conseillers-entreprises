class Company::SendSatisfactionEmailsJob < ApplicationJob
  queue_as :low_priority

  def perform
    return unless ENV['FEATURE_SEND_SATISFACTION_EMAILS'].to_b

    needs = Need
      .min_closed_at(11.days.ago..10.days.ago)
      .where(satisfaction_email_sent: false)
    needs.each do |need|
      CompanyMailer.satisfaction(need).deliver_later(queue: 'low_priority')
      need.update(satisfaction_email_sent: true)
    end
  end
end
