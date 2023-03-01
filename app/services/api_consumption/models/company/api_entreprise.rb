module ApiConsumption::Models
  class Company::ApiEntreprise < Company::Base
    def self.fields
      [
        :siren,
        :siret_siege_social,
        :categorie_entreprise,
        :diffusable_commercialement,
        :type,
        :personne_morale_attributs,
        :personne_physique_attributs,
        :forme_juridique,
        :activite_principale,
        :tranche_effectif_salarie,
        :etat_administratif,
        :economie_sociale_et_solidaire,
        :date_cessation,
        :date_creation,
        :rcs,
        :rm,
        :effectifs,
        :mandataires_sociaux
      ]
    end

    def name
      case type
      when "personne_morale"
        personne_morale_name
      when "personne_physique"
        personne_physique_name
      end
    end

    def inscrit_rcs
      return false if rcs.blank?
      rcs["error"].nil?
    end

    def inscrit_rm
      return false if rm.blank?
      rm["error"].nil?
    end

    def forme_juridique_libelle
      forme_juridique["libelle"]
    end

    def forme_juridique_code
      forme_juridique["code"]
    end

    def date_de_creation
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode.code_a10(naf_entreprise)
    end

    def naf_libelle
      @naf_libelle ||= (libelle_naf_entreprise || NafCode.naf_libelle(NafCode.level2_code(naf_entreprise), 'level2'))
    end

    def effectif
      @effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).effectif
    end

    def code_effectif
      @code_effectif ||= (@code_effectif_entreprise || Effectif::Format.new(effectifs, tranche_effectif_salarie).code_effectif)
    end

    def tranche_effectif
      @tranche_effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= Effectif::Format.new(effectifs, tranche_effectif_salarie).annee_effectif
    end

    def capital_social
      @capital_social ||= rcs&.dig('capital', 'montant')
    end

    private

    def personne_morale_name
      raison_sociale = personne_morale_attributs["raison_sociale"]
      sigle = personne_morale_attributs["sigle"]
      [raison_sociale, sigle].compact.join(" - ")
    end

    def personne_physique_name
      prenom = personne_physique_attributs["prenom_usuel"]
      nom = personne_physique_attributs["nom_usage"] || personne_physique_attributs["nom_naissance"]
      [prenom, nom].compact.join(" ")
    end
  end
end
