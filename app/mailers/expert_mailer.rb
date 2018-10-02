# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(person, diagnosis)
    @person = person
    if person.is_a? Expert
      @access_token = person.access_token
    end
    @diagnosis = diagnosis

    mail(
      to: @person.email_with_display_name,
      cc: @diagnosis.visit.advisor.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.visit.company_name),
      reply_to: [
        SENDER,
        @diagnosis.visit.advisor.email_with_display_name
      ]
    )
  end

  def remind_involvement(expert, matches_hash)
    @access_token = expert.access_token
    @matches_hash = matches_hash

    mail(
      to: expert.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end
end
