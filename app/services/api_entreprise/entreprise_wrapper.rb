# # frozen_string_literal: true

# module ApiEntreprise
#   class EntrepriseWrapper
#     attr_accessor :entreprise, :etablissement_siege

#     def initialize(data)
#       @entreprise = Entreprise.new(data.fetch('entreprise'))
#       set_custom_entreprise_fields
#       @etablissement_siege = ApiConsumption::Models::Facility.new(data.fetch('etablissement_siege'))
#     end

#     def name
#       company_name = @entreprise.nom_commercial

#       if company_name.blank?
#         company_name = @entreprise.raison_sociale
#       end

#       company_name.present? ? company_name.titleize : nil
#     end

#     def set_custom_entreprise_fields
#       inscription_rcs
#       inscription_rm
#     end

#     def inscription_rcs
#       return if entreprise.rcs.blank?
#       entreprise.inscrit_rcs = entreprise.rcs["errors"].nil?
#     end

#     def inscription_rm
#       return if entreprise.rm.blank?
#       entreprise.inscrit_rm = entreprise.rm["errors"].nil?
#     end
#   end
# end
