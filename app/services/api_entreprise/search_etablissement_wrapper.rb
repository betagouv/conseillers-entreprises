# frozen_string_literal: true

module ApiEntreprise
  class SearchEtablissementWrapper
    def initialize(api_entreprise_result)
      siege_social = api_entreprise_result.etablissement_siege
      entreprise = api_entreprise_result.entreprise

      @siret = siege_social.siret
      @nom = format_name(entreprise)
      @activite = siege_social.libelle_naf
      @lieu = format_lieu(siege_social)
      @code_region = siege_social.region_implantation['code']
    end

    private

    def format_name(entreprise)
      if entreprise.nom.present? && entreprise.prenom.present?
        entreprise.nom + ' ' + entreprise.prenom
      else
        entreprise.raison_sociale
      end
    end

    def format_lieu(siege_social)
      siege_social.adresse['l6']
    end
  end
end
