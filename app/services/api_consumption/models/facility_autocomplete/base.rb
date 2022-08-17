module ApiConsumption::Models
  class FacilityAutocomplete::Base < Base
    def self.fields
      [
        :entreprise,
        :etablissement_siege,
      ]
    end

    def company
      # a renseigner dans les models qui héritent de celui-ci
    end

    def facility
      # a renseigner dans les models qui héritent de celui-ci
    end

    def siret
      @siret ||= facility.siret
    end

    def siren
      @siren ||= company.siren
    end

    def nom
      @nom ||= company.name
    end

    def activite
      @activite ||= facility&.libelle_naf
    end

    def lieu
      # A renseigner dans les models qui héritent de celui-ci
    end

    def code_region
      # A renseigner dans les models qui héritent de celui-ci
    end

    def un_seul_etablissement
      true # A adapter suivant les models et les fournisseurs de données
    end

    def as_json(options = {})
      options[:except] ||= ['entreprise', 'etablissement_siege', 'etablissement', 'adresseEtablissement', 'adresse2Etablissement', 'periodesEtablissement']
      super(options).merge({
        'siret' => siret,
        'siren' => siren,
        'nom' => nom,
        'activite' => activite,
        'lieu' => lieu,
        'code_region' => code_region,
        'nombre_etablissements_ouverts' => nombre_etablissements_ouverts,
        'un_seul_etablissement' => un_seul_etablissement
      })
    end
  end
end
