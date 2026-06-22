class SendSolicitationGenericEmail
  def initialize(solicitation, email_type)
    @solicitation = solicitation
    @email_type = email_type
  end

  def valid?
    @email_type.present? && @solicitation.present? && (
      @email_type.to_sym == :bad_quality || SolicitationMailTemplate.exists?(email_type: @email_type.to_s)
    )
  end

  def send_email
    raise StandardError, I18n.t('errors.cancel_solicitation_with_email') unless valid?
    @solicitation.update(badge_ids: @solicitation.badge_ids + [email_type_to_badge_id])
    @solicitation.cancel!
    deliver_email
  end

  private

  # `bad_quality` is a built-in type without a template and has its own mailer
  # method. Other types are template-driven and go through `template`.
  def deliver_email
    if @email_type.to_sym == :bad_quality
      SolicitationMailer.bad_quality(@solicitation).deliver_later
    else
      SolicitationMailer.template(@solicitation, @email_type).deliver_later
    end
  end

  def email_type_to_badge_id
    badge = Badge.find_by('lower(title) = ?', badge_title.squish.downcase)
    badge ||= Badge.create(title: badge_title, color: Badge::DEFAULT_COLOR, category: :solicitations)
    badge.id
  end

  # `bad_quality` is a built-in type without a template: its badge title comes
  # from the locales. Other types use their template title.
  def badge_title
    template = SolicitationMailTemplate.find_by(email_type: @email_type.to_s)
    template&.title || I18n.t(@email_type, scope: 'solicitations.solicitation_actions.emails')
  end
end
