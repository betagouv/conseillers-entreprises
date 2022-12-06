module ApiConsumption::Models
  class FacilityAutocomplete::ApiEntreprise < FacilityAutocomplete::Base
    def company
      ApiConsumption::Models::Company::ApiEntreprise.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility::ApiEntreprise.new(etablissement_siege)
    end

    def lieu
      @lieu ||= facility&.adresse['l6']
    end

    def code_region
      @code_region ||= facility&.code_region
    end

    def nombre_etablissements_ouverts
      1
    end
  end
end
