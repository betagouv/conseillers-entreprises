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
        :effectifs,
        :effectifs_entreprise_annuel,
        :mandataires_sociaux,
        :forme_exercice,
        :description,
        :montant_capital,
        :errors
      ]
    end

    def display_mandataires_sociaux?
      !(mandataires_sociaux.is_a?(Hash) && mandataires_sociaux['error'])
    end

    def name
      case type
      when "personne_morale"
        personne_morale_name
      when "personne_physique"
        personne_physique_name
      end
    end

    def forme_juridique_libelle
      return nil unless forme_juridique
      forme_juridique["libelle"]
    end

    def forme_juridique_code
      return nil unless forme_juridique
      forme_juridique["code"]
    end

    def date_de_creation
      return '' if date_creation.blank?
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    # Ex : 6202A
    def naf_code
      activite_principale["code"].delete('.') if activite_principale["code"].present?
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode.code_a10(naf_code)
    end

    def naf_libelle
      @naf_libelle ||= (activite_principale["libelle"] || NafCode.naf_libelle(NafCode.level2_code(naf_code), 'level2'))
    end

    def effectif_regime_general
      effectifs_entreprise_annuel_array.select{ |hash| hash.value?('regime_general') }&.first&.merge({ annee: effectifs_entreprise_annuel_annee }) || {}
    end

    def effectif_regime_agricole
      effectifs_entreprise_annuel_array.select{ |hash| hash.value?('regime_agricole') }&.first&.merge({ annee: effectifs_entreprise_annuel_annee })
    end

    def effectif
      @effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).effectif
    end

    def code_effectif
      @code_effectif ||= (@code_effectif_entreprise || Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).code_effectif)
    end

    def tranche_effectif
      @tranche_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).annee_effectif
    end

    def capital_social
      montant_capital
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

    def effectifs_entreprise_annuel_array
      return [] unless effectifs_entreprise_annuel
      effectifs_entreprise_annuel['effectifs_annuel'] || []
    end

    def effectifs_entreprise_annuel_annee
      return [] unless effectifs_entreprise_annuel
      effectifs_entreprise_annuel['annee'] || nil
    end
  end
end
