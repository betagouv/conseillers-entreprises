# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseResponse::Rm < EntrepriseResponse::Base
    def formatted_data
      {
        'entreprise' =>  {
          'rm' => http_response.parse(:json)
        }
      }
    end

    def success?
      # on ne raise pas d'erreur si 'Not Found', ça signifie juste que l'ets n'est pas inscrit rm
      @error.nil? && (@http_response.status.success? || @http_response.code == 404) && @data['errors'].nil?
    end
  end
end
