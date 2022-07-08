module ApiConsumption::Models
  class FacilityAutocomplete::FromApiEntreprise < FacilityAutocomplete::Base
    def company
      ApiConsumption::Models::Company.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility.new(etablissement_siege)
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
