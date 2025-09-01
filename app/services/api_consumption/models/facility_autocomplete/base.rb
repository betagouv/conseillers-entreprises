module ApiConsumption::Models
  class FacilityAutocomplete::Base < Base
    def self.fields
      [
        :entreprise,
        :etablissement,
      ]
    end

    def company
      raise I18n.l('errors.missing_inherited_method')
    end

    def facility
      raise I18n.l('errors.missing_inherited_method')
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
      @activite ||= facility&.naf_libelle
    end

    def lieu
      @lieu ||= facility&.readable_locality
    end

    def code_region
      @code_region ||= facility&.code_region
    end

    def un_seul_etablissement # rubocop:disable Naming/PredicateMethod
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
