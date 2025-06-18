module WithTerritorialZones
  extend ActiveSupport::Concern

  included do
    scope :by_region, -> (region_code) {
      return all if region_code.blank?
      by_regions([region_code])
    }

    scope :by_regions, -> (regions_codes) do
      # territorial_zones.regions_codes inclue tout ou une partie des regions_codes
      joins(:territorial_zones).where("territorial_zones.regions_codes && ARRAY[?]::varchar[]", regions_codes)
    end

    scope :with_insee_codes, -> (insee_codes) {
      return nil if insee_codes.blank?
      #    Si self.insee_codes contient tous les insee_codes
      #   insee_codes n'est pas un champs en base mais une methode de l'instance
      select do |record|
        (record.insee_codes - insee_codes).empty? || (insee_codes - record.insee_codes).empty?
      end
    }
  end

  def insee_codes
    territorial_zones.map do |tz|
      if tz.zone_type == "commune"
        tz.code
      else
        tz.territory_model.communes.map(&:code)
      end
    end.flatten.uniq
  end

  def regions
    territorial_zones.flat_map(&:region).compact.uniq
  end
end
