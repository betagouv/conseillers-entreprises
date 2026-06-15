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
    SolicitationMailer.send(@email_type, @solicitation).deliver_later
  end

  private

  def email_type_to_badge_id
    template = SolicitationMailTemplate.find_by(email_type: @email_type.to_s)
    badge_title = template&.title.presence || I18n.t(@email_type, scope: 'solicitations.solicitation_actions.emails', default: @email_type.to_s.tr('_', ' ').capitalize)
    badge = Badge.find_by('lower(title) = ?', badge_title.squish.downcase)
    badge = Badge.create(title: badge_title, color: "#000000", category: :solicitations) if badge.nil?
    badge.id
  end
end
