class SolicitationMailerPreview < ActionMailer::Preview
  def bad_quality
    SolicitationMailer.bad_quality(Solicitation.joins(:landing_subject).status_canceled.have_badge('mauvaise_qualité').find_random)
  end

  def employee_labor_law
    SolicitationMailer.employee_labor_law(random_solicitation)
  end

  def creation
    SolicitationMailer.creation(random_solicitation)
  end

  def siret
    SolicitationMailer.siret(random_solicitation)
  end

  def mediateurs
    SolicitationMailer.mediateurs(random_solicitation)
  end

  def formalites_asso_agri_sci
    SolicitationMailer.formalites_asso_agri_sci(random_solicitation)
  end

  def moderation
    SolicitationMailer.moderation(random_solicitation)
  end

  def sie_tva_and_others
    SolicitationMailer.sie_tva_and_others(random_solicitation)
  end

  def sie_sip_declare_and_pay
    SolicitationMailer.sie_sip_declare_and_pay(random_solicitation)
  end

  def intermediary
    SolicitationMailer.intermediary(random_solicitation)
  end

  def recruitment_foreign_worker
    SolicitationMailer.recruitment_foreign_worker(random_solicitation)
  end

  def no_expert
    SolicitationMailer.no_expert(random_solicitation)
  end

  def carsat
    SolicitationMailer.carsat(random_solicitation)
  end

  def tns_training
    SolicitationMailer.tns_training(random_solicitation)
  end

  def kbis_extract
    SolicitationMailer.kbis_extract(random_solicitation)
  end

  def retirement_liberal_professions
    SolicitationMailer.retirement_liberal_professions(random_solicitation)
  end

  def administrations_collectivites
    SolicitationMailer.administrations_collectivites(random_solicitation)
  end

  private

  def random_solicitation
    Solicitation.step_complete.joins(:landing_subject).find_random
  end
end
