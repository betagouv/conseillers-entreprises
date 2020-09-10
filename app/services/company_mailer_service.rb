# frozen_string_literal: true

class CompanyMailerService
  def self.send_satisfaction_emails
    return unless ENV['FEATURE_SEND_SATISFACTION_EMAILS'].to_b

    needs = Need
      .min_closed_at(11.days.ago..10.days.ago)
      .not_satisfaction_email_sent
    needs.each do |need|
      CompanyMailer.satisfaction(need).deliver_later
      need.update(satisfaction_email_sent: true)
    end
  end

  def self.send_newsletter_subscription_emails
    return unless ENV['FEATURE_SEND_NEWSLETTER_SUBSCRIPTION_EMAILS'].to_b

    diagnoses = Diagnosis
      .min_closed_at(13.days.ago..12.days.ago)
      .not_newsletter_subscription_email_sent
    diagnoses.each do |diagnosis|
      contact = Mailjet::Contactslistsignup.all(email: diagnosis.visitee.email, contacts_list: ENV['MAILJET_NEWSLETTER_ID'])
      CompanyMailer.newsletter_subscription(diagnosis).deliver_later if contact.blank?
      diagnosis.update(newsletter_subscription_email_sent: true)
    end
  end
end
