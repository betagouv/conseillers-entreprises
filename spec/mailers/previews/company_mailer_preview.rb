class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation_from_pde
    CompanyMailer.confirmation_solicitation(Solicitation.where(cooperation: nil).where.associated(:landing_subject).sample)
  end

  def confirmation_solicitation_from_iframe_or_api
    CompanyMailer.confirmation_solicitation(Solicitation.where.not(cooperation: nil).where.associated(:landing_subject).sample)
  end

  def taking_care_solicitation
    CompanyMailer.notify_taking_care(Diagnosis.completed.sample.matches.sample)
  end

  def not_reachable
    CompanyMailer.notify_not_reachable(Diagnosis.completed.sample.matches.sample)
  end

  def satisfaction
    CompanyMailer.satisfaction(Need.where(status: :done).sample)
  end

  def retention
    CompanyMailer.retention(Need.where(status: :done).sample)
  end

  def failed_need
    CompanyMailer.failed_need(Diagnosis.completed.from_solicitation.sample.needs.sample)
  end

  def solicitation_relaunch_company
    CompanyMailer.solicitation_relaunch_company(Solicitation.status_step_company.where.not(uuid: nil).sample)
  end

  def solicitation_relaunch_description
    CompanyMailer.solicitation_relaunch_description(Solicitation.status_step_description.where.not(uuid: nil).sample)
  end

  def intelligent_retention
    CompanyMailer.intelligent_retention(Need.where(status: :done).where.associated(:solicitation).sample, EmailRetention.all.sample)
  end

  def not_yet_taken_care
    CompanyMailer.not_yet_taken_care(Diagnosis.completed.sample.solicitation)
  end
end
