class CompanyEmails::SendRetentionEmailsJob < ApplicationJob
  queue_as :low_priority

  def perform
    return unless ENV['FEATURE_SEND_RETENTION_EMAILS'].to_b || Rails.env.test?
    needs = Need
      .joins(:diagnosis)
      .where(diagnoses: { retention_email_sent: false },
                     created_at: (5.months.ago - 2.days)..(5.months.ago))
      .with_status_done
    needs.each do |need|
      CompanyMailer.retention(need).deliver_later(queue: 'low_priority')
      need.diagnosis.update(retention_email_sent: true)
    end
  end
end
