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

    def insee_code
      @insee_code ||= adresseEtablissement["codeCommuneEtablissement"]
    end

    def naf_code_complet
      periodesEtablissement[0]['activitePrincipaleEtablissement']
    end

    def naf_libelle
      @naf_libelle ||= NafCode.naf_libelle(NafCode.level2_code(naf_code_complet), 'level2')
    end

    def code_postal
      @code_postal ||= adresseEtablissement["codePostalEtablissement"]
    end

    def libelle_commune
      @libelle_commune ||= adresseEtablissement["libelleCommuneEtablissement"]
    end
  end
end
