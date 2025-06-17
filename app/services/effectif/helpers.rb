# frozen_string_literal: true

# Permet de gérer l'affichage des effectifs en prenant le meilleur de 2 champs possibles
module Effectif
  class Helpers
    def self.simple_effectif_collection
      %w[0 1 6 10 20 50 250].map do |code|
        [Effectif::CodeEffectif.new(code).simple_effectif, code]
      end
    end
  end
end
