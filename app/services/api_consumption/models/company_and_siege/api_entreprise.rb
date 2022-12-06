module ApiConsumption::Models
  class CompanyAndSiege::ApiEntreprise < CompanyAndSiege
    def self.fields
      [
        :entreprise,
        :etablissement_siege,
      ]
    end

    def company
      ApiConsumption::Models::Company::ApiEntreprise.new(entreprise)
    end

    def siege_facility
      ApiConsumption::Models::Facility::ApiEntreprise.new(etablissement_siege)
    end
  end
end
