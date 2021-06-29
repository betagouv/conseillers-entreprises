# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseWrapper
    attr_accessor :entreprise, :etablissement_siege

    def initialize(data)
      @entreprise = Entreprise.new(data.fetch('entreprise'))
      @etablissement_siege = Etablissement.new(data.fetch('etablissement_siege'))
    end

    def name
      company_name = @entreprise.nom_commercial

      if company_name.blank?
        company_name = @entreprise.raison_sociale
      end

      company_name.present? ? company_name.titleize : nil
    end

    def inscrit_rcs
      return if entreprise.rcs.blank?
      entreprise.rcs["errors"].nil?
    end
  end
end
