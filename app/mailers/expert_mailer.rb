class ExpertMailer < ApplicationMailer
  default template_path: 'mailers/expert_mailer'
  helper :institutions
  helper :status

  layout 'expert_mailers'

  before_action :set_expert_params
  before_deliver :filter_deleted_experts

  def set_expert_params
    @expert = params[:expert]
    throw :abort if @expert.nil?

    @support_user = @expert.support_user
    @institution_logo_name = @expert.institution.logo&.filename
  end

  def filter_deleted_experts
    throw :abort if @expert.deleted?
  end

  def notify_company_needs
    @need = params[:need]
    @diagnosis = @need.diagnosis
    @solicitation = @need.solicitation

    mail(
      to: @expert.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name)
    )
  end

  def first_notification_help
    # Email du premier besoin reçu
    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.first_notification_help.subject')
    )
  end

  def remind_involvement
    # On ne relance pas les MER les + recentes
    inbox_needs = @expert.needs_quo_active
    @displayed_needs = inbox_needs.matches_sent_at(Range.new(nil, 4.days.ago)).first(7)
    return if @displayed_needs.empty?
    @others_needs_quo_count = (inbox_needs - @displayed_needs).count

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end

  def positioning_rate_reminders
    # Envoyé depuis les paniers qualité
    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.positioning_rate_reminders.subject')
    )
  end

  def re_engagement
    # Email pour ceux n'ont pas reçu de besoin depuis un moment
    @need = params[:need]

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.re_engagement.subject')
    )
  end

  def closing_good_practice
    # Envoyé depuis optimisation - stock en cours
    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.closing_good_practice.subject')
    )
  end

  def last_chance
    @need = params[:need]
    @match = @expert.received_matches.find_by(need: @need)

    mail(
      to: @expert.email_with_display_name,
      reply_to: @support_user.email_with_display_name,
      subject: t('mailers.expert_mailer.last_chance.subject', company: @need.company.name)
    )
  end

  def match_feedback
    @feedback = params[:feedback]
    return if @feedback.nil?

    @author = @feedback.user
    @match = @expert.received_matches.find_by(need: @feedback.need.id)

    mail(to: @expert.email_with_display_name,
         subject: t('mailers.expert_mailer.match_feedback.subject', company_name: @feedback.need.company))
  end
end
