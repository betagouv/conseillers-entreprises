module CreateDiagnosis
  class CreateMatches
    attr_accessor :solicitation, :diagnosis

    def initialize(diagnosis)
      @diagnosis = diagnosis
      @solicitation = diagnosis.solicitation
    end

    def call
      diagnosis.needs.each do |need|
        expert_subjects = CreateDiagnosis::FindRelevantExpertSubjects.new(need).call

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
  end
end
