module ApiConsumption::Models
  class Facility::ApiInsee < Facility
    def self.fields
      [
        :siren,
        :nic,
        :siret,
        :statutDiffusionEtablissement,
        :dateCreationEtablissement,
        :trancheEffectifsEtablissement,
        :anneeEffectifsEtablissement,
        :activitePrincipaleRegistreMetiersEtablissement,
        :dateDernierTraitementEtablissement,
        :etablissementSiege,
        :nombrePeriodesEtablissement,
        :adresseEtablissement,
        :adresse2Etablissement,
        :periodesEtablissement
      ]
    end

    def naf_code_complet
      periodesEtablissement[0]['activitePrincipaleEtablissement']
    end

    def libelle_naf
      @libelle_naf ||= NafCode::libelle_naf('level2', NafCode::level2_code(naf_code_complet))
    end

    def insee_code
      @insee_code ||= adresseEtablissement["codeCommuneEtablissement"]
    end

    def code_postal
      @code_postal ||= adresseEtablissement["codePostalEtablissement"]
    end

    def libelle_commune
      @libelle_commune ||= adresseEtablissement["libelleCommuneEtablissement"]
    end

    def readable_locality
      [code_postal, libelle_commune].compact_blank.join(' ').presence
    end

    def code_region
      @code_region ||= I18n.t(code_postal[0..1], scope: 'department_code_to_region_code')
    end

    def commune
      @commune ||= Commune.find_or_create_by insee_code: insee_code
    end
  end
end
