# frozen_string_literal: true

# Permet de gérer l'affichage des effectifs en prenant le meilleur de 2 champs possibles
module Effectif
  class Format
    def initialize(effectifs, tranche_effectif)
      # si nil est passé, les params par défaut sont pas pris en compte
      @effectifs = effectifs
      @tranche_effectif = tranche_effectif
    end

    # Si on a des données présentes et + récentes dans @effectifs, on prend cette référence
    def formatter
      if @effectifs.nil? || @effectifs['error'].present? || (@effectifs['annee'] >= @tranche_effectif["date_reference"])
        EffectifRange.new(@tranche_effectif)
      else
        Effectifs.new(@effectifs)
      end
    end

    def code_effectif
      formatter.code_effectif
    end

    def intitule_effectif
      formatter.intitule_effectif
    end

    def effectif
      formatter.effectif
    end

    def annee_effectif
      formatter.annee_effectif
    end
  end
end
