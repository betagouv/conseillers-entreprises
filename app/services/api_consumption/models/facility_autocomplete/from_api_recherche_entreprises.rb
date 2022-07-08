module ApiConsumption::Models
  class FacilityAutocomplete::FromApiRechercheEntreprises < FacilityAutocomplete::Base
    def company
      ApiConsumption::Models::Company::FromApiRechercheEntreprises.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility::FromApiRechercheEntreprises.new(etablissement_siege)
    end

    def lieu
      @lieu ||= facility&.readable_locality
    end

    def code_region
      @code_region ||= facility&.code_region
    end

    def nombre_etablissements_ouverts
      company.nombre_etablissements_ouverts
    end
  end
end
