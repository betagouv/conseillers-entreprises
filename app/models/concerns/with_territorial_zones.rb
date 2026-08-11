module WithTerritorialZones
  extend ActiveSupport::Concern

  included do
    has_many :territorial_zones, as: :zoneable, dependent: :destroy, inverse_of: :zoneable
    accepts_nested_attributes_for :territorial_zones, allow_destroy: true
    validate :territorial_zones_codes_are_known, on: :import

    scope :by_region, -> (region_code) {
      return all if region_code.blank?
      result = joins(:territorial_zones)
        .where("territorial_zones.regions_codes && ARRAY[?]::varchar[]", [region_code])
      result = result.or(territorial_level_national) if respond_to?(:territorial_level_national)
      result.distinct
    }

    scope :with_insee_codes, -> (insee_codes) {
      return nil if insee_codes.blank?
      #   Conserve les enregistrements dont le périmètre territorial recoupe
      #   `insee_codes`. Une intersection (et non une inclusion stricte) suffit :
      #   une seule commune orpheline fusionnée, obsolète ou rattachée à une
      #   autre région ne doit pas exclure toute l'antenne de la hiérarchie.
      #   `insee_codes` n'est pas un champ en base mais une méthode de l'instance.
      includes(:territorial_zones).select do |record|
        record.insee_codes.intersect?(insee_codes)
      end
    }

    def territorial_zones_codes_are_known
      codes_by_zone_type = territorial_zones.pluck(:zone_type, :code)
        .group_by(&:first).transform_values{ it.map(&:last) }

      codes_by_zone_type.each do |zone_type, codes|
        known_codes = WithTerritorialZones.known_insee_codes(zone_type)
        unknown_codes = (Set.new(codes) - known_codes)
        if unknown_codes.present?
          zone = I18n.t(zone_type, scope: 'activerecord.attributes.territorial_zone')
          errors.add(:territorial_zones, :not_found, zone_type: zone, codes: unknown_codes.to_a.to_sentence)
        end
      end
    end
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

  def known_insee_codes(zone_type)
    @codes ||= {}
    model_class = TerritorialZone::ZONE_TYPE_MODELS[zone_type]
    @codes[model_class] ||= Set.new(model_class.all.map(&:code))
  end
  module_function :known_insee_codes
end
