module ApiConsumption::Models
  class Facility::ApiRechercheEntreprises < Facility
    def self.fields
      [
        :activite_principale,
        :activite_principale_registre_metier,
        :adresse_complete,
        :adresse_complete_secondaire,
        :cedex,
        :commune,
        :complement_adresse,
        :code_pays_etranger,
        :code_postal,
        :date_creation,
        :date_debut_activite,
        :departement,
        :distribution_speciale,
        :etat_adiministratif,
        :geo_id,
        :indice_repetition,
        :latitude,
        :libelle_cedex,
        :libelle_commune,
        :libelle_commune_etranger,
        :libelle_pays_etranger,
        :libelle_voie,
        :longitude,
        :numero_voie,
        :siret,
        :tranche_effectif_salarie,
        :type_voie,
      ]
    end

    def naf_code_complet
      activite_principale
    end

    def libelle_naf
      @libelle_naf ||= NafCode::libelle_naf('level2', NafCode::level2_code(naf_code_complet))
    end

    def insee_code
      @insee_code ||= commune
    end

    def readable_locality
      [code_postal, libelle_commune].compact_blank.join(' ').presence
    end

    def code_region
      @code_region ||= I18n.t(departement, scope: 'department_code_to_region_code')
    end

    def commune
      @commune ||= Commune.find_or_create_by insee_code: insee_code
    end
  end
end
