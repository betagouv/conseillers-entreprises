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

  def self.send_newsletter_subscription_emails
    return unless ENV['FEATURE_SEND_NEWSLETTER_SUBSCRIPTION_EMAILS'].to_b

    diagnoses = Diagnosis
      .min_closed_at(13.days.ago..12.days.ago)
      .not_newsletter_subscription_email_sent
    api_instance = SibApiV3Sdk::ContactsApi.new
    diagnoses.each do |diagnosis|
      begin
        contact = api_instance.get_contact_info(diagnosis.visitee.email)
        CompanyMailer.newsletter_subscription(diagnosis).deliver_later unless contact.list_ids&.include?(ENV['SENDINBLUE_NEWSLETTER_ID'].to_i)
        diagnosis.update(newsletter_subscription_email_sent: true)
      rescue SibApiV3Sdk::ApiError => e
        Raven.tags_context(email: diagnosis.visitee.email) do
          Raven.capture_exception(e)
        end
      end
    end
  end
end
