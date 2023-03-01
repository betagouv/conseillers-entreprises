module ApiConsumption::Models
  class Facility::ApiEntreprise < Facility
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
        :effectifs
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

    def effectif
      @effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).effectif
    end

    def code_effectif
      @code_effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).code_effectif
    end

    def tranche_effectif
      @tranche_effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).annee_effectif
    end

    def code_postal
      adresse&.dig('code_postal')
    end

    def libelle_commune
      adresse&.dig('localite')
    end
  end
end
