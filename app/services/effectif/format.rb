# frozen_string_literal: true

# Permet de gérer l'affichage des effectifs en prenant le meilleur de 2 champs possibles
module Effectif
  class Format
    def initialize(effectifs, tranche_effectif)
      @effectifs = effectifs
      @tranche_effectif = tranche_effectif
    end

    # Si on a des données présentes et + récentes dans @effectifs, on prend cette référence
    def formatter
      if effectifs_empty || tranche_effectif_more_recent_than_effectifs
        EffectifRange.new(@tranche_effectif)
      else
        Effectifs.new(@effectifs)
      end
    end

    def code_effectif
      formatter.code_effectif rescue nil
    end

    def intitule_effectif
      CodeEffectif.new(code_effectif).intitule_effectif
    end

    def effectif
      formatter.effectif rescue nil
    end

    def annee_effectif
      formatter.annee_effectif rescue nil
    end

    private

    def effectifs_empty
      @effectifs.nil? || @effectifs['value'].nil? || @effectifs['error'].present?
    end

    def tranche_effectif_more_recent_than_effectifs
      @tranche_effectif.present? && @tranche_effectif["date_reference"].present? && @tranche_effectif["date_reference"] > @effectifs['annee']
    end
  end
end
