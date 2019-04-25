class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs
    match = match_with_expert
    ExpertMailer.notify_company_needs(match.expert, match.diagnosis)
  end

  def remind_involvement
    match = match_with_expert
    matches = match.expert.received_matches
    ExpertMailer.remind_involvement(match.expert, matches.sample(2), matches.sample(2))
  end

  private

  def match_with_expert
    Match.where.not(expert_skill: nil).sample
  end
end
