class SolicitationMailerPreview < ActionMailer::Preview
  def bad_quality_difficulties
    SolicitationMailer.bad_quality_difficulties(random_solicitation)
  end

  def bad_quality_investment
    SolicitationMailer.bad_quality_investment(random_solicitation)
  end

  def out_of_region
    SolicitationMailer.out_of_region(random_solicitation)
  end

  def employee_labor_law
    SolicitationMailer.employee_labor_law(random_solicitation)
  end

  def particular_retirement
    SolicitationMailer.particular_retirement(random_solicitation)
  end

  def creation
    SolicitationMailer.creation(random_solicitation)
  end

  def siret
    SolicitationMailer.siret(random_solicitation)
  end

  def moderation
    SolicitationMailer.moderation(random_solicitation)
  end

  private

  def random_solicitation
    Solicitation.joins(:landing_subject).sample
  end
end
