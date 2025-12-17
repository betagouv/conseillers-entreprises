class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs_from_pde
    expert = expert_with_quo_matches
    need = expert.received_needs.find_random
    need.solicitation = Solicitation.where(cooperation_id: nil).find_random
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def notify_company_needs_from_partner
    expert = expert_with_quo_matches
    need = expert.received_needs.find_random
    solicitation = Solicitation.all.find_random
    need.solicitation = solicitation
    solicitation.landing = Landing.cooperation.find_random
    solicitation.landing.cooperation.update(root_url: 'https://test.com')
    solicitation.landing.update(url_path: '/formulaire')
    ExpertMailer.with(expert: expert, need: need).notify_company_needs
  end

  def first_notification_help
    expert = expert_with_quo_matches
    ExpertMailer.with(expert: expert).first_notification_help
  end

  def remind_involvement
    expert = Match.sent.status_quo.where(created_at: ..4.days.ago, archived_at: nil).joins(:expert).where(experts: { deleted_at: nil }).find_random.expert
    ExpertMailer.with(expert: expert).remind_involvement
  end

  def positioning_rate_reminders
    expert = Expert.not_deleted.many_pending_needs.find_random
    ExpertMailer.with(expert: expert).positioning_rate_reminders
  end

  def last_chance
    expert = expert_with_quo_matches
    need = expert.received_needs.find_random
    ExpertMailer.with(expert: expert, need: need).last_chance
  end

  def re_engagement
    expert = expert_with_quo_matches
    need = expert.received_needs.find_random
    ExpertMailer.with(expert: expert, need: need).re_engagement
  end

  def match_feedback
    feedback = Feedback.category_need.find_random
    ExpertMailer.with(expert: feedback.need.experts.find_random, feedback: feedback).match_feedback
  end

  def closing_good_practice
    expert = expert_with_quo_matches
    ExpertMailer.with(expert: expert).closing_good_practice
  end

  private

  def expert_with_quo_matches
    Expert.not_deleted.with_quo_matches.find_random
  end
end
