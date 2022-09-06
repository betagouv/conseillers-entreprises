module ApiConsumption::Models
  class Company::ApiInsee < Company
    def self.fields
      [
        :activite_principale,
        :categorie_entreprise,
        :date_creation,
        :date_mise_a_jour,
        :economie_sociale_solidaire,
        :etat_administratif,
        :is_entrepreneur_individuel,
        :nature_juridique,
        :nom_complet,
        :nom_raison_sociale,
        :nombre_etablissements,
        :nombre_etablissements_ouverts,
        :section_activite_principale,
        :siren,
        :tranche_effectif_salarie,:etatAdministratifUniteLegale,
        :statutDiffusionUniteLegale,
        :dateCreationUniteLegale,
        :categorieJuridiqueUniteLegale,
        :denominationUniteLegale,
        :sigleUniteLegale,
        :denominationUsuelle1UniteLegale,
        :denominationUsuelle2UniteLegale,
        :denominationUsuelle3UniteLegale,
        :sexeUniteLegale,
        :nomUniteLegale,
        :nomUsageUniteLegale,
        :prenom1UniteLegale,
        :prenom2UniteLegale,
        :prenom3UniteLegale,
        :prenom4UniteLegale,
        :prenomUsuelUniteLegale,
        :pseudonymeUniteLegale,
        :activitePrincipaleUniteLegale,
        :nomenclatureActivitePrincipaleUniteLegale,
        :identifiantAssociationUniteLegale,
        :economieSocialeSolidaireUniteLegale,
        :caractereEmployeurUniteLegale,
        :trancheEffectifsUniteLegale,
        :anneeEffectifsUniteLegale,
        :nicSiegeUniteLegale,
        :dateDernierTraitementUniteLegale,
        :categorieEntreprise,
        :anneeCategorieEntreprise
      ]
    end

    def name
      company_name = denominationUniteLegale.presence || [nomUniteLegale, prenomUsuelUniteLegale].compact.join(' ').presence
      company_name.present? ? company_name.titleize : nil
    end

    def naf_libelle
      @naf_libelle ||= NafCode::naf_libelle('level2', NafCode::level2_code(activitePrincipaleUniteLegale))
    end
  end
end
