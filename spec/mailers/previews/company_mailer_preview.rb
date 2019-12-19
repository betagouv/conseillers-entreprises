class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation
    CompanyMailer.confirmation_solicitation(email)
  end

  def taking_care_by_expert
    CompanyMailer.taking_care_by_expert(match)
  end

  private

  def email
    Solicitation.all.sample.email
  end

  def match
    Match.all.sample
  end
end
