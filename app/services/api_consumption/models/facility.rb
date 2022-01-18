module ApiConsumption::Models
  class Facility < Base
    def self.fields
      [
        :siege_social,
        :siret,
        :naf,
        :libelle_naf,
        :date_mise_a_jour,
        :tranche_effectif_salarie_etablissement,
        :date_creation_etablissement,
        :region_implantation,
        :commune_implantation,
        :pays_implantation,
        :adresse,
        :diffusable_commercialement,
        :opcoSiren,
        :effectifs
      ]
    end

    def insee_code
      @insee_code ||= commune_implantation['code']
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode::code_a10(naf)
    end

    def naf_libelle
      @naf_libelle ||= libelle_naf
    end

    def effectif
      @effectif ||= EffectifRange.new(effectifs).effectif
    end

    def code_effectif
      @code_effectif ||= EffectifRange.new(effectifs).code_effectif
    end

    def tranche_effectif
      @tranche_effectif ||= EffectifRange.new(effectifs).intitule_effectif
    end

    def readable_locality
      code_postal = adresse&.dig('code_postal')
      localite = adresse&.dig('localite')
      [code_postal, localite].compact_blank.join(' ').presence
    end

    def region
      @region ||= region_implantation['value']
    end

    def code_region
      @code_region ||= region_implantation['code']
    end

    def pays
      @pays ||= pays_implantation['value']
    end

    def opco
      @opco ||= Institution.opco.find_by(siren: opcoSiren)
    end

    def commune
      @commune ||= Commune.find_or_create_by insee_code: insee_code
    end
  end
end
