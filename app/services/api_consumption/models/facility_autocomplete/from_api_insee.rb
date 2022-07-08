module ApiConsumption::Models
  class FacilityAutocomplete::FromApiInsee < FacilityAutocomplete::Base
    def self.fields
      [
        :entreprise,
        :etablissement,
        :nombre_etablissements_ouverts
      ]
    end

    def company
      ApiConsumption::Models::Company::FromApiInsee.new(entreprise)
    end

    def facility
      ApiConsumption::Models::Facility::FromApiInsee.new(etablissement)
    end

    def lieu
      @lieu ||= facility&.readable_locality
    end

    def code_region
      @code_region ||= facility&.code_region
    end

    def nombre_etablissements_ouverts
      nombre_etablissements_ouverts
    end
  end
end
