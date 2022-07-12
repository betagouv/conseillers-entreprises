module ApiConsumption::Models
  class FacilityAutocomplete::Base < Base
    def self.fields
      [
        :entreprise,
        :etablissement_siege,
      ]
    end

    def company
      # a renseigner
    end

    def facility
      # a renseigner
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
      # A renseigner
    end

    def code_region
      # A renseigner
    end

    def afficher_etablissement
      true # A adapter
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
        'afficher_etablissement' => afficher_etablissement
      })
    end
  end
end
