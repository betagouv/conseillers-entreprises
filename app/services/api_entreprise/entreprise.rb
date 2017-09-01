# frozen_string_literal: true

module ApiEntreprise
  class Entreprise
    attr_accessor :entreprise, :etablissement_siege

    def initialize(data)
      @entreprise = EntrepriseInformation.new(data.fetch('entreprise'))
      @etablissement_siege = Etablissement.new(data.fetch('etablissement_siege'))
    end
  end
end
