class CreateMatches
  # Recherche d'un établissement via l'appel à des API externes
  # Utilisable pour des champs en auto-complétion
  attr_accessor :solicitation, :diagnosis

  def initialize(diagnosis)
    @diagnosis = diagnosis
    @solicitation = diagnosis.solicitation
  end

  def call
    diagnosis.needs.each do |need|
      expert_subjects = relevant_expert_subjects(need)

      if expert_subjects.present?
        matches_params = expert_subjects.map{ |es| { expert: es.expert, subject: es.subject } }
        need.matches.create(matches_params)
      else
        diagnosis.errors.add(:matches, :preselected_institution_has_no_relevant_experts)
      end
    end

    diagnosis.matches.reload # solicitation.matches is a through relationship; make sure it’s up to date.
    diagnosis
  end

  def relevant_expert_subjects(need)
    ExpertSubject
      .in_commune(need.facility.commune)
      .of_subject(need.subject)
      .of_institution(institutions)
      .in_company_registres(need.company)
  end

  private

  def institutions
    solicitation.preselected_institutions || Institution.not_deleted
  end
end
