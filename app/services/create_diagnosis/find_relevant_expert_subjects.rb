module CreateDiagnosis
  class FindRelevantExpertSubjects
    attr_accessor :need

    def initialize(need)
      @need = need
    end

    def call
      ExpertSubject
        .in_commune(need.facility.commune)
        .of_subject(need.subject)
        .of_institution(institutions)
        .in_company_registres(need.company)
    end

    private

    def institutions
      @institutions ||= (need&.solicitation&.preselected_institutions&.presence || Institution.not_deleted)
    end
  end
end
