# frozen_string_literal: true

# Permet de gérer l'affichage des effectifs en prenant le meilleur de 2 champs possibles
module Effectif
  class EffectifRange
    def initialize(params)
      # si nil est passé, les params par défaut sont pas pris en compte
      @annee = params["date_reference"]
      @code = params['code']
    end

    def code_effectif
      @code
    end

    def intitule_effectif
      I18n.t(code_effectif, scope: 'codes_effectif', default: I18n.t('simple_effectif.Autre'))
    end

    def effectif
      nil
    end

    def annee_effectif
      @annee
    end
  end
end
