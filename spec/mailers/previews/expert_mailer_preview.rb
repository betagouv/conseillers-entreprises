class ExpertMailerPreview < ActionMailer::Preview
  def notify_company_needs
    match = match_with_person
    ExpertMailer.notify_company_needs(match.person, match.diagnosis)
  end

  private

  def match_with_person
    Match.where.not(relay: nil).or(Match.where.not(assistance_expert: nil)).sample
  end
end
