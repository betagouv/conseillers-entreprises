module ApiConsumption::Models
  class Company::ApiRechercheEntreprises < Company
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
        :tranche_effectif_salarie,
      ]
    end

    def name
      company_name = nom_complet.presence || nom_raison_sociale.presence
      company_name.present? ? company_name.titleize : nil
    end

    def naf_libelle
      @naf_libelle ||= NafCode::naf_libelle(NafCode::level2_code(activite_principale), 'level2')
    end
  end
end
