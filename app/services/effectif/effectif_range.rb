# frozen_string_literal: true

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

    def effectif
      nil
    end

    def annee_effectif
      @annee
    end
  end
end
