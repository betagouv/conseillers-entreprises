module ApiConsumption::Models
  class FacilityAutocomplete::ApiRechercheEntreprises < FacilityAutocomplete::Base
    def self.fields
      [
        :entreprise,
        :etablissement_siege,
      ]
    end

    def company
      ApiConsumption::Models::Company::ApiRechercheEntreprises.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility::ApiRechercheEntreprises.new(etablissement_siege)
    end

    def nombre_etablissements_ouverts
      @nombre_etablissements_ouverts ||= company.nombre_etablissements_ouverts
    end

    def un_seul_etablissement
      nombre_etablissements_ouverts == 1
    end
  end
end
