# frozen_string_literal: true

class CompanyMailerService
  def self.send_newsletter_subscription_emails
    diagnoses = Diagnosis
      .min_closed_at(13.days.ago..12.days.ago)
    diagnoses.each do |diagnosis|
      contact = Mailjet::Contactslistsignup.all(email: diagnosis.visitee.email, contacts_list: ENV['MAILJET_NEWSLETTER_ID'])
      CompanyMailer.newsletter_subscription(diagnosis).deliver_later if contact.blank?
      diagnosis.update(newsletter_subscription_email_sent: true)
    end
  end
end
