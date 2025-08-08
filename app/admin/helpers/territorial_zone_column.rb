module Admin
  module Helpers
    module TerritorialZoneColumn
      def territorial_zone_column_content(resource)
        return if resource.territorial_zones.empty?

        zone_types = TerritorialZone.zone_types.keys
        div do
          zone_types.each do |zone_type|
            count = if resource.territorial_zones.loaded?
              resource.territorial_zones.count { |tz| tz.zone_type == zone_type }
            else
              resource.territorial_zones.where(zone_type: zone_type).count
            end
            next unless count.positive?

            zone_label = I18n.t(zone_type, scope: 'activerecord.attributes.territorial_zone')
            div("#{zone_label} : #{count}")
          end
        end
      end
    end

    Arbre::Element.include TerritorialZoneColumn
  end
end
