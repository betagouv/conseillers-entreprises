module WithTerritorialZones
  extend ActiveSupport::Concern

  included do
    has_many :territorial_zones, as: :zoneable, dependent: :destroy, inverse_of: :zoneable
    accepts_nested_attributes_for :territorial_zones, allow_destroy: true

    scope :by_region, -> (region_code) {
      return all if region_code.blank?
      joins(:territorial_zones)
        .where("territorial_zones.regions_codes && ARRAY[?]::varchar[]", [region_code])
        .distinct
    }

    scope :with_insee_codes, -> (insee_codes) {
      return nil if insee_codes.blank?
      #    Si self.insee_codes contient tous les insee_codes
      #   insee_codes n'est pas un champs en base mais une methode de l'instance
      includes(:territorial_zones).select do |record|
        (record.insee_codes - insee_codes).empty? || (insee_codes - record.insee_codes).empty?
      end
    }
  end

  def insee_codes
    cache_key = ["insee_codes", self.class.name, self.id, territorial_zones.ids]

    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      calculate_insee_codes
    end
  end

  def regions
    territorial_zones.flat_map(&:regions).compact.uniq
  end

  def intersects_with_insee_codes?(insee_codes_array)
    return false if insee_codes_array.empty?

    # Version optimisée : pas besoin de calculer tous les insee_codes
    territorial_zones.any? do |tz|
      tz.territory_model.includes_any_commune_code?(insee_codes_array)
    end
  end

  private

  def calculate_insee_codes
    zones = territorial_zones.to_a

    # Traite les communes directement
    commune_codes = zones.select { |tz| tz.zone_type == "commune" }.map(&:code)

    # Groupe les autres zones par type pour optimiser les requêtes
    other_zones = zones.reject { |tz| tz.zone_type == "commune" }
    territory_codes = other_zones.flat_map do |tz|
      tz.territory_model.communes.map(&:code)
    end

    (commune_codes + territory_codes).uniq
  end
end
