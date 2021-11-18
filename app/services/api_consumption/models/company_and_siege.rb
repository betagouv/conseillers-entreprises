module ApiConsumption::Models
  class CompanyAndSiege < Base
    def self.fields
      [
        :entreprise,
        :etablissement_siege,
      ]
    end

    def company
      ApiConsumption::Models::Company.new(entreprise)
    end

    def siege_facility
      ApiConsumption::Models::Facility.new(etablissement_siege)
    end
  end
end
