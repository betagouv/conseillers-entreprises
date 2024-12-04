# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  default template_path: 'mailers/expert_mailer'
  helper :institutions

  layout 'expert_mailers'

  def notify_company_needs
    with_expert_init do
      @need = params[:need]
      @diagnosis = @need.diagnosis
      @solicitation = @need.solicitation

      mail(
        to: @expert.email_with_display_name,
        subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name)
      )
    end
  end

  def first_notification_help
    # Email du premier besoin reçu
    with_expert_init do
      mail(
        to: @expert.email_with_display_name,
        reply_to: @support_user.email_with_display_name,
        subject: t('mailers.expert_mailer.first_notification_help.subject')
      )
    end
  end

  def remind_involvement
    with_expert_init do
      # On ne relance pas les MER les + recentes
      needs_quo = @expert.needs_quo.matches_sent_at(Range.new(nil, 4.days.ago))
      @firsts_needs_quo = needs_quo.first(7)
      @others_needs_quo_count = (needs_quo - @firsts_needs_quo).count

      return if needs_quo.empty?

      mail(
        to: @expert.email_with_display_name,
        reply_to: @support_user.email_with_display_name,
        subject: t('mailers.expert_mailer.remind_involvement.subject')
      )
    end
  end

  def positioning_rate_reminders
    # Envoyé depuis les paniers qualité
    with_expert_init do

      mail(
        to: @expert.email_with_display_name,
        reply_to: @support_user.email_with_display_name,
        subject: t('mailers.expert_mailer.positioning_rate_reminders.subject')
      )
    end
  end

  def re_engagement
    # Email pour ceux n'ont pas reçu de besoin depuis un moment
    with_expert_init do
      @need = params[:need]

      mail(
        to: @expert.email_with_display_name,
        reply_to: @support_user.email_with_display_name,
        subject: t('mailers.expert_mailer.re_engagement.subject')
      )
    end
  end

  def last_chance
    with_expert_init do
      @need = params[:need]
      @match = @expert.received_matches.find_by(need: @need)

      mail(
        to: @expert.email_with_display_name,
        reply_to: @support_user.email_with_display_name,
        subject: t('mailers.expert_mailer.last_chance.subject', company: @need.company.name)
      )
    end
  end

  def match_feedback
    with_expert_init do
      @feedback = params[:feedback]
      return if @feedback.nil?

      @author = @feedback.user
      @match = @expert.received_matches.find_by(need: @feedback.need.id)

      mail(to: @expert.email_with_display_name,
           subject: t('mailers.expert_mailer.match_feedback.subject', company_name: @feedback.need.company))
    end
  end

  private

  def with_expert_init
    @expert = params[:expert]
    return if @expert.deleted?
    @support_user = @expert.support_user
    @institution_logo_name = @expert.institution.logo&.filename
    yield
  end
end
