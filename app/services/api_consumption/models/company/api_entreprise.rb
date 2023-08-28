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
        :effectifs_entreprise_annuel,
        :mandataires_sociaux,
        :forme_exercice,
        :rne_rcs,
        :rne_rnm
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
      # api rcs peut retourner false juste parce qu'il n'a pas la donnée
      if api_rcs_value == true
        return true
      else
        return api_rne_rcs_value
      end
    end

    def inscrit_rm
      # api rm peut retourner false juste parce qu'il n'a pas la donnée
      if api_rm_value == true
        return true
      else
        return api_rne_rnm_value
      end
    end

    def forme_juridique_libelle
      forme_juridique["libelle"]
    end

    def forme_juridique_code
      forme_juridique["code"]
    end

    def date_de_creation
      return '' if date_creation.blank?
      I18n.l(Time.strptime(date_creation.to_s, '%s').in_time_zone.to_date)
    end

    # Ex : 6202A
    def naf_code
      activite_principale["code"].delete('.')
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
      @capital_social ||= rcs&.dig('capital', 'montant')
    end

    def activite_liberale
      if has_liberal_forme_exercice || has_liberal_naf_code
        return true
      else
        return false
      end
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

    def has_liberal_forme_exercice
      forme_exercice.present? && forme_exercice == ("INDEPENDANTE" || "LIBERALE_REGLEMENTEE")
    end

    def has_liberal_naf_code
      forme_juridique_code == '1000' && liberal_naf_codes.include?(naf_code)
    end

    def liberal_naf_codes
      ['0240Z', '1813Z', '4332C', '4611Z', '4612A', '4612B', '4613Z', '4614Z', '4615Z', '4616Z', '4617A', '4617B', '4618Z', '4619A', '4619B', '4773Z', '5821Z', '5829A', '5829B', '5829C', '6201Z', '6202A', '6202B', '6203Z', '6209Z', '6311Z', '6312Z', '6399Z', '6420Z', '6430Z', '6611Z', '6612Z', '6619A', '6619B', '6621Z', '6622Z', '6629Z', '6630Z', '6831Z', '6832B', '6910Z', '6920Z', '7010Z', '7021Z', '7022Z', '7111Z', '7112A', '7112B', '7120B', '7211Z', '7219Z', '7220Z', '7311Z', '7312Z', '7320Z', '7410Z', '7430Z', '7490A', '7490B', '7500Z', '7740Z', '7810Z', '7830Z', '8010Z', '8020Z', '8030Z', '8211Z', '8219Z', '8230Z', '8291Z', '8299Z', '8421Z', '8423Z', '8510Z', '8520Z', '8531Z', '8532Z', '8541Z', '8542Z', '8551Z', '8552Z', '8559A', '8559B', '8560Z', '8610Z', '8621Z', '8622A', '8622B', '8622C', '8623Z', '8690B', '8690D', '8690E', '8690F', '9001Z', '9002Z', '9003A', '9003B', '9102Z', '9103Z', '9104Z', '9609Z', '9700Z', '9900Z']
    end

    def effectifs_entreprise_annuel_array
      effectifs_entreprise_annuel['effectifs_annuel'] || []
    end

    def effectifs_entreprise_annuel_annee
      effectifs_entreprise_annuel['annee'] || nil
    end

    def api_rcs_value
      return false if rcs.nil?
      rcs["error"].nil?
    end

    def api_rne_rcs_value
      return false if rne_rcs.nil?
      rne_rcs['estPresent']
    end

    def api_rm_value
      return false if rm.nil?
      rm["error"].nil?
    end

    def api_rne_rnm_value
      return false if rne_rnm.nil?
      rne_rnm['estPresent']
    end
  end
end
