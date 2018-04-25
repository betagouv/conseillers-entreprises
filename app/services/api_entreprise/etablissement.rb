# frozen_string_literal: true

module ApiEntreprise
  class Etablissement < OpenStruct
    def location
      location_hash = dig('commune_implantation')
      return nil if !location_hash
      postal_code = location_hash.dig('code')
      town_name = location_hash.dig('value')&.titleize
      "#{postal_code} #{town_name}".presence
    end
  end
end
