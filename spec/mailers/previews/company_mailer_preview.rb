class CompanyMailerPreview < ActionMailer::Preview
  def confirmation_solicitation_from_pde
    CompanyMailer.confirmation_solicitation(Solicitation.where(cooperation: nil).where.associated(:landing_subject).find_random)
  end

  def confirmation_solicitation_from_iframe_or_api
    CompanyMailer.confirmation_solicitation(Solicitation.where.not(cooperation: nil).where.associated(:landing_subject).find_random)
  end

  def taking_care_solicitation
    CompanyMailer.notify_taking_care(Diagnosis.completed.find_random.matches.find_random)
  end

  def not_reachable
    CompanyMailer.notify_not_reachable(Diagnosis.completed.find_random.matches.find_random)
  end

  def satisfaction
    CompanyMailer.satisfaction(Need.where(status: :done).find_random)
  end

  def retention
    CompanyMailer.retention(Need.where(status: :done).find_random)
  end

  def failed_need
    CompanyMailer.failed_need(Diagnosis.completed.from_solicitation.find_random.needs.find_random)
  end

  def solicitation_relaunch_company
    CompanyMailer.solicitation_relaunch_company(Solicitation.status_step_company.where.not(uuid: nil).find_random)
  end

  def solicitation_relaunch_description
    CompanyMailer.solicitation_relaunch_description(Solicitation.status_step_description.where.not(uuid: nil).find_random)
  end

  def intelligent_retention
    CompanyMailer.intelligent_retention(Need.where(status: :done).where.associated(:solicitation).find_random, EmailRetention.all.find_random)
  end

  def not_yet_taken_care
    CompanyMailer.not_yet_taken_care(Diagnosis.completed.find_random.solicitation)
  end
end
