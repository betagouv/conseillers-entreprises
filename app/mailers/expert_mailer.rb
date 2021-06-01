# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'
  helper :institutions

  def notify_company_needs(expert, need)
    @expert = expert
    @need = need
    @diagnosis = need.diagnosis
    @solicitation = need.solicitation

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name)
    )

    # Also send a reset link to the expert’s users that have never used their account.
    # In practice, this only happens to Experts that used to have no corresponding User and
    # for which we created User accounts automatically.
    expert.users.not_deleted.filter(&:never_used_account?).each do |user|
      user.send_reset_password_instructions
    end
  end

  def first_notification_help(expert)
    @expert = expert
    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.first_notification_help.subject')
    )
  end

  def remind_involvement(expert)
    @expert = expert

    @needs_quo = expert.needs_quo
    @needs_taking_care = expert.needs_taking_care
    @needs_others_taking_care = expert.needs_others_taking_care

    return if @needs_taking_care.empty? && @needs_quo.empty? && @needs_others_taking_care.empty?

    return if @expert.deleted?
    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end
end
