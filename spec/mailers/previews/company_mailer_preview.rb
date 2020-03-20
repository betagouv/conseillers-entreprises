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

  def taking_care_by_expert
    match = Match.joins(:diagnosis)
      .where.not(id: Match.with_deleted_expert)
      .where.not(diagnoses: { advisor: User.not_deleted.support_users })
      .sample
    CompanyMailer.notify_taking_care(match)
  end

  def taking_care_by_support
    match = Match.joins(:diagnosis)
      .where.not(id: Match.with_deleted_expert)
      .where(diagnoses: { advisor: User.not_deleted.support_users })
      .sample
    CompanyMailer.notify_taking_care(match)
  end

  private

  def email
    Solicitation.all.sample.email
  end

  def match
    Match.all.sample
  end
end
