module ApiConsumption::Models
  class Facility::ApiRechercheEntreprises < Facility::Base
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

    def insee_code
      @insee_code ||= commune
    end

    def naf_code_complet
      activite_principale
    end

    def naf_libelle
      @naf_libelle ||= NafCode.naf_libelle(NafCode.level2_code(naf_code_complet), 'level2')
    end

    def code_departement
      departement
    end
  end
end
