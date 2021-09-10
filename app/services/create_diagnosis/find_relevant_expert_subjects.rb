module CreateDiagnosis
  class FindRelevantExpertSubjects
    attr_accessor :need

    def initialize(need)
      @need = need
    end

    def call
      ExpertSubject
        .joins(:not_deleted_expert)
        .in_commune(need.facility.commune)
        .of_subject(need.subject)
        .of_institution(institutions)
        .in_company_registres(need.company)
    end

    private

    def institutions
      @institutions ||= (Institution.where(id: need&.solicitation&.preselected_institution) || Institution.not_deleted)
    end
  end
end
