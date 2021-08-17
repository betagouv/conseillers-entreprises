class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation_from_pde
    CompanyMailer.confirmation_solicitation(Solicitation.where(institution: nil).sample)
  end

  def confirmation_solicitation_from_iframe
    CompanyMailer.confirmation_solicitation(Solicitation.where.not(institution: nil).sample)
  end

  def taking_care_solicitation
    CompanyMailer.notify_taking_care(Diagnosis.completed.from_solicitation.sample.matches.sample)
  end

  def taking_care_visit
    CompanyMailer.notify_taking_care(Diagnosis.completed.from_visit.sample.matches.sample)
  end

  def satisfaction
    CompanyMailer.satisfaction(Need.where(status: :done).sample)
  end

  def newsletter_subscription
    CompanyMailer.newsletter_subscription(Diagnosis.completed.sample)
  end
end
