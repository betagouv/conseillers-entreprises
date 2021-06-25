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
    expert = active_expert
    ExpertMailer.remind_involvement(expert)
  end

  private

  def active_expert
    Expert.not_deleted.with_active_matches.sample
  end
end
