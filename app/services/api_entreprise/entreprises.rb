# # frozen_string_literal: true

# module ApiEntreprise
#   class Entreprises
#     attr_accessor :token, :options

#     def initialize(token, options = {})
#       @token = token
#       @options = options
#     end

#     def fetch(siren)
#       Rails.cache.fetch("entreprise-#{siren}", expires_in: 12.hours) do
#         fetch_from_api(siren)
#       end
#     end

#     def fetch_from_api(siren)
#       connection = HTTP

#       entreprise_request = EntrepriseRequests.new(token, siren, connection, options).call

#       if !entreprise_request.success?
#         raise ApiEntrepriseError, entreprise_request.error_message
#       end

#       EntrepriseWrapper.new(entreprise_request.data)
#     end
#   end
# end
