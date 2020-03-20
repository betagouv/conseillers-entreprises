class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation
    CompanyMailer.confirmation_solicitation(email)
  end

  def notify_matches_made_solicitation
    CompanyMailer.notify_matches_made(Diagnosis.completed.from_solicitation.sample)
  end

  def notify_matches_made_visit
    CompanyMailer.notify_matches_made(Diagnosis.completed.from_visit.sample)
  end

  def taking_care_solicitation
    CompanyMailer.notify_taking_care(Diagnosis.completed.from_solicitation.sample.matches.sample)
  end

  def taking_care_visit
    CompanyMailer.notify_taking_care(Diagnosis.completed.from_visit.sample.matches.sample)
  end

  private

  def email
    Solicitation.all.sample.email
  end

  def match
    Match.all.sample
  end
end
