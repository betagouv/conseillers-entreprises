class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs
    match = match_with_person
    ExpertMailer.notify_company_needs(match.person, match.diagnosis)
  end

  def remind_involvement
    match = match_with_person
    matches = Match.of_relay_or_expert(match.person)
    ExpertMailer.remind_involvement(match.person, matches.sample(2), matches.sample(2))
  end

  private

  def match_with_person
    Match.where.not(relay: nil).or(Match.where.not(assistance_expert: nil)).sample
  end
end
