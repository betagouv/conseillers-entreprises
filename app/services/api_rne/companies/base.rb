# frozen_string_literal: true

module ApiRne::Companies
  class Base < ApiRne::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiRne::Request
    private

    def url_key
      @url_key ||= 'companies/'
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}"
    end
  end

  class Responder < ApiRne::Responder
    def format_data
      registres = @http_request.data.dig('formality','content','registreAnterieur')
      {
        "forme_exercice" => @http_request.data.dig('formality', 'content', 'formeExerciceActivitePrincipale'),
        "activites_secondaires" => grab_activites_secondaires(@http_request.data)
      }
    end

    private

    def grab_activites_secondaires(data)
      personne = data.dig('formality', 'content', 'personneMorale') || data.dig('formality', 'content', 'personnePhysique') || data.dig('formality', 'content', 'exploitation')

      etablissement_principal = {}
      etablissement_principal['siret'] = personne.dig('etablissementPrincipal', 'descriptionEtablissement', 'siret')
      activites_etablissement_principal = personne.dig('etablissementPrincipal', 'activites') || []
      etablissement_principal['activites'] = grab_etablissement_activites(activites_etablissement_principal)

      autres_etablissements = []
      personne['autresEtablissements']&.each do |etablissement|
        item = {}
        item['siret'] = etablissement['descriptionEtablissement']['siret']
        activites = etablissement['activites'] || []
        item['activites'] = grab_etablissement_activites(activites)
        autres_etablissements << item
      end
      {
        'etablissement_principal' => etablissement_principal,
        'autres_etablissements' => autres_etablissements
      }
    end

    def grab_etablissement_activites(activites)
      activites.map do |activite|
        {
          'formeExercice' => activite['formeExercice'],
          'codeApe' => activite['codeApe'],
          'codeAprm' => activite['codeAprm']
        }
      end
    end
  end
end
