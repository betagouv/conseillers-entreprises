module DiagnosisCreation
  class NewDiagnosis
    attr_accessor :solicitation

    def initialize(solicitation = nil)
      @solicitation = solicitation
    end

    def call
      Diagnosis.new(solicitation: @solicitation,
                    facility: Facility.new(company: company))
    end

    private

    def company
      Company.new(name: @solicitation&.full_name)
    end
  end
end
