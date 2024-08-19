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
        "activites_secondaires" => grab_activites_secondaires(@http_request.data),
        "rne_rcs" => registres.present? ? registres['rncs'] : nil,
        "rne_rnm" => registres.present? ? registres['rnm'] : nil,
      }
    end

    private

    def grab_activites_secondaires(data)
      activites_secondaires = []
      personne = data.dig('formality', 'content', 'personneMorale') || data.dig('formality', 'content', 'personnePhysique') || data.dig('formality', 'content', 'exploitation')

      activites_etablissement_principal = personne.dig('etablissementPrincipal', 'activites')
      activites_etablissement_principal&.each do |activite|
        activites_secondaires << {
          'formeExercice' => activite['formeExercice'],
          "descriptionDetaillee" => activite['descriptionDetaillee'],
          'codeApe' => activite['codeApe'],
          'codeAprm' => activite['codeAprm']
        }
      end

      personne['autresEtablissements']&.each do |etablissement|
        activites_autres_etablissements = etablissement['activites']
        activites_autres_etablissements&.each do |activite|
          activites_secondaires << {
            'formeExercice' => activite['formeExercice'],
            "descriptionDetaillee" => activite['descriptionDetaillee'],
            'codeApe' => activite['codeApe'],
            'codeAprm' => activite['codeAprm']
          }
        end
      end
      activites_secondaires
    end
  end
end
