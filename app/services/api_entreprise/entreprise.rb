# frozen_string_literal: true

module ApiEntreprise
  class Entreprise
    attr_accessor :entreprise, :etablissement_siege

    def initialize(data)
      @entreprise = EntrepriseInformation.new(data.fetch('entreprise'))
      @etablissement_siege = Etablissement.new(data.fetch('etablissement_siege'))
    end

    def name
      company_name = @entreprise.nom_commercial
      company_name = @entreprise.raison_sociale if company_name.blank?
      company_name.present? ? company_name.titleize : nil
    end
  end
end
