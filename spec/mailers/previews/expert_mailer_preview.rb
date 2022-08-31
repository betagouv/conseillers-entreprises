class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_from_pde
    expert = active_expert
    need = expert.received_needs.sample
    need.solicitation = Solicitation.joins(:landing).where(landing: { partner_url: [nil, ''] }).sample
    ExpertMailer.notify_company_needs(expert, need)
  end

  def notify_company_needs_from_partner
    expert = active_expert
    need = expert.received_needs.sample
    solicitation = Solicitation.all.sample
    need.solicitation = solicitation
    solicitation.landing = Landing.all.sample
    solicitation.landing.update(partner_url: 'https://test.com/formulaire')
    ExpertMailer.notify_company_needs(expert, need)
  end

  def first_notification_help
    expert = active_expert
    ExpertMailer.first_notification_help(expert)
  end

  def remind_involvement
    expert = Match.sent.status_quo.where(created_at: ..4.days.ago, archived_at: nil).joins(:expert).where(experts: { deleted_at: nil }).sample.expert
    ExpertMailer.remind_involvement(expert)
  end

  def positioning_rate_reminders
    expert = PositionningRate::Collection.new(Expert.not_deleted).critical_rate.sample
    ExpertMailer.positioning_rate_reminders(expert, User.support_users.sample)
  end

  private

  def active_expert
    Expert.not_deleted.with_active_matches.sample
  end
end
