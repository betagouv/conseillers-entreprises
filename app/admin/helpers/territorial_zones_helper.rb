module Admin
  module Helpers
    module TerritorialZonesHelper
      def displays_territories(territorial_zones)
        TerritorialZone.zone_types.each_key do |zone_type|
          antenne_territorial_zones = territorial_zones.select { |tz| tz.zone_type == zone_type }
          next if antenne_territorial_zones.empty?
          attributes_table title: I18n.t(zone_type, scope: "activerecord.attributes.territorial_zone").pluralize do
            model = DecoupageAdministratif.const_get(zone_type.camelize)
            antenne_territorial_zones.map do |tz|
              row(tz.code) do
                model_instance = model.find(tz.code)
                name = model_instance.nom
                if zone_type == "epci"
                  communes_names = []
                  model_instance.communes.sort_by(&:nom).map do |commune|
                    communes_names << "#{commune.nom} (#{commune.code})"
                  end
                  name = name + "<br/>" + communes_names.join(', ')
                end
                name.html_safe
              end
            end
          end
        end
      end

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

    Arbre::Element.include TerritorialZonesHelper
  end
end
