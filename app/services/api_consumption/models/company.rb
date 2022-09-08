module ApiConsumption::Models
  class Company < Base
    def self.fields
      [
        :siren,
        :capital_social,
        :numero_tva_intracommunautaire,
        :forme_juridique,
        :forme_juridique_code,
        :nom_commercial,
        :procedure_collective,
        :enseigne,
        :libelle_naf_entreprise,
        :naf_entreprise,
        :raison_sociale,
        :siret_siege_social,
        :code_effectif_entreprise,
        :date_creation,
        :nom,
        :prenom,
        :date_radiation,
        :categorie_entreprise,
        :tranche_effectif_salarie_entreprise,
        :mandataires_sociaux,
        :etat_administratif,
        :diffusable_commercialement,
        :rcs,
        :rm,
        :effectifs,
        :nombre_etablissements_ouverts
      ]
    end

    def name
      company_name = nom_commercial.presence || raison_sociale.presence || nom_complet.presence || nom_raison_sociale.presence
      company_name.present? ? company_name.titleize : nil
    end

    def inscrit_rcs
      return false if rcs.blank?
      rcs["error"].nil?
    end

    def inscrit_rm
      return false if rm.blank?
      rm["error"].nil?
    end

    def date_de_creation
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode::code_a10(naf_entreprise)
    end

    def naf_libelle
      @naf_libelle ||= (libelle_naf_entreprise || NafCode::naf_libelle('level2', NafCode::level2_code(naf_entreprise)))
    end

    def effectif
      @effectif ||= EffectifFromApi::Format.new(effectifs, tranche_effectif_salarie_entreprise).effectif
    end

    def code_effectif
      @code_effectif ||= (@code_effectif_entreprise || EffectifFromApi::Format.new(effectifs, tranche_effectif_salarie_entreprise).code_effectif)
    end

    def tranche_effectif
      @tranche_effectif ||= EffectifFromApi::Format.new(effectifs, tranche_effectif_salarie_entreprise).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= EffectifFromApi::Format.new(effectifs, tranche_effectif_salarie_entreprise).annee_effectif
    end
  end
end
