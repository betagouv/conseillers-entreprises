module ApiConsumption::Models
  class FacilityAutocomplete::ApiInsee < FacilityAutocomplete::Base
    def self.fields
      [
        :entreprise,
        :etablissement,
        :nombre_etablissements_ouverts
      ]
    end

    def siren
      @siren ||= facility.siren
    end

    def company
      @company ||= ::ApiConsumption::Models::Company::ApiInsee.new(entreprise)
    end

    def facility
      @facility ||= ::ApiConsumption::Models::Facility::ApiInsee.new(etablissement)
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
