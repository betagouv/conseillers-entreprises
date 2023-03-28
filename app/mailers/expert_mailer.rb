# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  default template_path: 'mailers/expert_mailer'
  helper :institutions

  def notify_company_needs(expert, need)
    @expert = expert
    return if @expert.deleted?

    @need = need
    @diagnosis = need.diagnosis
    @solicitation = need.solicitation

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name)
    )
  end

  def first_notification_help(expert)
    @expert = expert
    return if @expert.deleted?

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.first_notification_help.subject')
    )
  end

  def remind_involvement(expert)
    @expert = expert
    return if @expert.deleted?

    # On ne relance pas les MER les + recentes
    @needs_quo = expert.needs_quo.matches_created_at(Range.new(nil, 4.days.ago))

    return if @needs_quo.empty?

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end

  def positioning_rate_reminders(expert, support_user)
    @expert = expert
    return if @expert.deleted?

    @support_user = support_user

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end

  def re_engagement(expert, support_user, need)
    @expert = expert
    @need = need
    return if @expert.deleted?

    @support_user = support_user

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.re_engagement.subject')
    )
  end

  def last_chance(expert, need, support_user)
    @expert = expert
    return if @expert.deleted?

    @need = need
    @match = @expert.received_matches.find_by(need: @need)
    @support_user = support_user

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.last_chance.subject', company: @need.company.name)
    )
  end
end
