module ApiConsumption::Models
  class Facility::ApiEntreprise < Facility::Base
    def self.fields
      [
        :siret,
        :siege_social,
        :etat_administratif,
        :date_fermeture,
        :enseigne,
        :activite_principale,
        :tranche_effectif_salarie,
        :diffusable_commercialement,
        :date_creation,
        :date_derniere_mise_a_jour,
        :unite_legale,
        :adresse,
        :effectifs_etablissement_mensuel, # a partir d'ici, données agglomérées d'autres appels API
        :opco_fc,
        :activites_secondaires,
        :liste_idcc,
        :errors
      ]
    end

    def insee_code
      @insee_code ||= adresse&.dig('code_commune')
    end

    def naf_code
      @naf_code ||= activite_principale['code']
    end

    def naf_code_a10
      @naf_code_a10 ||= NafCode.code_a10(naf_code)
    end

    def naf_libelle
      @naf_libelle ||= activite_principale['libelle']
    end

    def effectif_regime_general
      effectifs_etablissement_mensuel_array.select{ |hash| hash.value?('regime_general') }&.first
    end

    def effectif_regime_agricole
      effectifs_etablissement_mensuel_array.select{ |hash| hash.value?('regime_agricole') }&.first
    end

    def effectif
      @effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).effectif
    end

    def code_effectif
      @code_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).code_effectif
    end

    def tranche_effectif
      @tranche_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).intitule_effectif
    end

    def annee_effectif
      @annee_effectif ||= Effectif::Format.new(effectif_regime_general, tranche_effectif_salarie).annee_effectif
    end

    def code_postal
      adresse&.dig('code_postal')
    end

    def libelle_commune
      adresse['libelle_commune']
    end

    def opco
      @opco ||= (opco_from_idcc || france_competence_opco)
    end

    def idcc
      @idcc ||= liste_idcc&.first
    end

    def nature_activites
      return [] if rne_etablissement.blank?
      rne_etablissement['activites'].pluck('formeExercice').uniq.compact_blank
    end

    def nafa_codes
      return [] if rne_etablissement.blank?
      rne_etablissement['activites'].pluck('codeAprm').uniq.compact_blank
    end

    private

    def rne_etablissement
      return nil if activites_secondaires.blank?
      @rne_etablissement = if activites_secondaires.dig('etablissement_principal', 'siret') == siret
        activites_secondaires['etablissement_principal']
      else
        activites_secondaires["autres_etablissements"].find{ |etablissement| etablissement['siret'] == siret }
      end
    end

    def effectifs_etablissement_mensuel_array
      return [] unless effectifs_etablissement_mensuel
      effectifs_etablissement_mensuel['effectifs_mensuels'] || []
    end

    def effectifs_etablissement_mensuel_annee
      return [] unless effectifs_etablissement_mensuel
      effectifs_etablissement_mensuel['annee'] || nil
    end

    def france_competence_opco
      Institution.opco.find_by(france_competence_code: france_competence_code) if france_competence_code.present?
    end

    def france_competence_code
      @france_competence_code ||= opco_fc&.dig('opcoRattachement', 'code')
    end

    def opco_from_idcc
      @idcc_to_opco ||= YAML.load_file("#{Rails.root.join("config", "data", "idcc_to_opco.yml")}")
      opco_siren = @idcc_to_opco[idcc]
      Institution.opco.find_by(siren: opco_siren) if opco_siren.present?
    end
  end
end
