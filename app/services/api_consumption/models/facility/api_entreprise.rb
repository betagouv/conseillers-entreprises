module ApiConsumption::Models
  class Facility::ApiEntreprise < Facility::Base
    def self.fields
      [
        :siret,
        :siege_social,
        :etat_administratif,
        :date_fermeture,
        :enseigne,
        :activite_principale,
        :tranche_effectif_salarie,
        :diffusable_commercialement,
        :date_creation,
        :date_derniere_mise_a_jour,
        :unite_legale,
        :adresse,
        :opcoSiren, # a partir d'ici, données agglomérées d'autres appels API
        :idcc,
        :effectifs_etablissement_mensuel
      ]
    end

    def insee_code
      @insee_code ||= adresse&.dig('code_commune')
    end

    def naf_code
      @naf_code ||= activite_principale['code']
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode.code_a10(naf_code)
    end

    def naf_libelle
      @naf_libelle ||= activite_principale['libelle']
    end

    def effectif_regime_general
      effectifs_etablissement_mensuel_array.select{ |hash| hash.value?('regime_general') }&.first
    end

    def effectif_regime_agricole
      effectifs_etablissement_mensuel_array.select{ |hash| hash.value?('regime_agricole') }&.first
    end

    def effectif
      @effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).effectif
    end

    def code_effectif
      @code_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).code_effectif
    end

    def tranche_effectif
      @tranche_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).annee_effectif
    end

    def code_postal
      adresse&.dig('code_postal')
    end

    def libelle_commune
      adresse['libelle_commune']
    end

    private

    def effectifs_etablissement_mensuel_array
      effectifs_etablissement_mensuel['effectifs_mensuels'] || []
    end

    def effectifs_etablissement_mensuel_annee
      effectifs_etablissement_mensuel['annee'] || nil
    end
  end
end
