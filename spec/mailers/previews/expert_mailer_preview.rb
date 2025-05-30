class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_from_pde
    expert = active_expert
    need = expert.received_needs.sample
    need.solicitation = Solicitation.where(cooperation_id: nil).sample
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def notify_company_needs_from_partner
    expert = active_expert
    need = expert.received_needs.sample
    solicitation = Solicitation.all.sample
    need.solicitation = solicitation
    solicitation.landing = Landing.cooperation.sample
    solicitation.landing.cooperation.update(root_url: 'https://test.com')
    solicitation.landing.update(url_path: '/formulaire')
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def first_notification_help
    expert = active_expert
    ExpertMailer.with(expert: expert).first_notification_help
  end

  def remind_involvement
    expert = Match.sent.status_quo.where(created_at: ..4.days.ago, archived_at: nil).joins(:expert).where(experts: { deleted_at: nil }).sample.expert
    ExpertMailer.with(expert: expert).remind_involvement
  end

  def positioning_rate_reminders
    expert = Expert.not_deleted.many_pending_needs.sample
    ExpertMailer.with(expert: expert).positioning_rate_reminders
  end

  def last_chance
    expert = active_expert
    need = expert.received_needs.sample
    ExpertMailer.with(expert: expert, need: need).last_chance
  end

  def re_engagement
    expert = active_expert
    need = expert.received_needs.sample
    ExpertMailer.with(expert: expert, need: need).re_engagement
  end

  def match_feedback
    feedback = Feedback.category_need.sample
    ExpertMailer.with(expert: feedback.need.experts.sample, feedback: feedback).match_feedback
  end

  def closing_good_practice
    expert = active_expert
    ExpertMailer.with(expert: expert).closing_good_practice
  end

  private

  def active_expert
    Expert.not_deleted.with_active_matches.sample
  end
end
