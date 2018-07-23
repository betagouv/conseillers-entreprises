# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(person, params)
    if person.is_a? Expert
      @access_token = person.access_token
    end

    @params = params

    mail(
      to: "#{person.full_name} <#{person.email}>",
      cc: "#{params[:advisor].full_name} <#{params[:advisor].email}>",
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: params[:company_name]),
      reply_to: reply_to(params),
    )
  end

  def remind_involvement(expert, matches_hash)
    @access_token = expert.access_token
    @matches_hash = matches_hash

    mail(
      to: "#{expert.full_name} <#{expert.email}>",
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end

  private

  def reply_to(params)
    [
      "#{I18n.t('app_name')} <#{SENDER_EMAIL}>",
      "#{params[:advisor].full_name} <#{params[:advisor].email}>"
    ]
  end
end
