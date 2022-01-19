# frozen_string_literal: true

class CompanyMailerService
  def self.send_satisfaction_emails
    return unless ENV['FEATURE_SEND_SATISFACTION_EMAILS'].to_b

    needs = Need
      .min_closed_at(11.days.ago..10.days.ago)
      .where(satisfaction_email_sent: false)
    needs.each do |need|
      CompanyMailer.satisfaction(need).deliver_later
      need.update(satisfaction_email_sent: true)
    end
  end

  def self.send_retention_emails
    return unless ENV['FEATURE_SEND_RETENTION_EMAILS'].to_b || Rails.env.test?
    needs = Need
      .joins(:diagnosis)
      .where(diagnoses: { retention_email_sent: false },
             created_at: (5.months.ago - 2.days)..(5.months.ago))
      .with_status_done
    needs.each do |need|
      CompanyMailer.retention(need).deliver_later
      need.diagnosis.update(retention_email_sent: true)
    end
  end
end
