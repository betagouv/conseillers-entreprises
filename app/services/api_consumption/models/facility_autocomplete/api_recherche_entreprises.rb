module ApiConsumption::Models
  class FacilityAutocomplete::ApiRechercheEntreprises < FacilityAutocomplete::Base
    def company
      ApiConsumption::Models::Company::ApiRechercheEntreprises.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility::ApiRechercheEntreprises.new(etablissement_siege)
    end

    def lieu
      @lieu ||= facility&.readable_locality
    end

    def code_region
      @code_region ||= facility&.code_region
    end

    def nombre_etablissements_ouverts
      @nombre_etablissements_ouverts ||= company.nombre_etablissements_ouverts
    end

    def afficher_etablissement
      nombre_etablissements_ouverts == 1
    end
  end
end
