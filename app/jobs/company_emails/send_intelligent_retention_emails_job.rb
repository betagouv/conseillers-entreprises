class CompanyEmails::SendIntelligentRetentionEmailsJob < ApplicationJob
  queue_as :low_priority

  def perform
    EmailRetention.find_each do |email_retention|
      end_of_2022 = Date.new(2022, 12, 01)
      needs = Need.with_exchange
        .where(retention_sent_at: false)
        .min_closed_with_help_at(end_of_2022..email_retention.waiting_time.months.ago)
        .where(subject: email_retention.subject)

      needs.each do |need|
        CompanyMailer.intelligent_retention(need, email_retention).deliver_later(queue: 'low_priority')
        need.update(retention_sent_at: Time.zone.now)
      end
    end
  end
end
