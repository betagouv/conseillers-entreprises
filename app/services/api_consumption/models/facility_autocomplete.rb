module ApiConsumption::Models
  class FacilityAutocomplete < Base
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

    def siret
      @siret ||= siege_facility.siret
    end

    def nom
      @nom ||= company.name
    end

    def activite
      @activite ||= siege_facility&.libelle_naf
    end

    def lieu
      @lieu ||= siege_facility&.adresse['l6']
    end

    def code_region
      @code_region ||= siege_facility&.code_region
    end

    def as_json(options = {})
      options[:except] ||= ['entreprise', 'etablissement_siege']
      super(options).merge({
        'siret' => siret,
        'nom' => nom,
        'activite' => activite,
        'lieu' => lieu,
        'code_region' => code_region,
      })
    end
  end
end
