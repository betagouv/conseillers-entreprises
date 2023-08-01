# frozen_string_literal: true

module Effectif
  class Effectifs
    def initialize(params)
      # si nil est passé, les params par défaut sont pas pris en compte
      @annee = params["annee"]
      @effectifs = params["value"].to_f
    end

    def code_effectif
      @code_effectif ||= find_code_effectif
    end

    def effectif
      @effectifs
    end

    def annee_effectif
      @annee
    end

    private

    def find_code_effectif
      return nil if @effectifs.blank?
      code = nil
      CodeEffectif::RANGES.each do |range|
        if @effectifs.to_i >= range[:min] && @effectifs.to_i <= range[:max]
          code = range[:code]
          break
        end
      end
      code
    end
  end
end
