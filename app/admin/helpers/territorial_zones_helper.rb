module Admin
  module Helpers
    module TerritorialZonesHelper
      def displays_territories(territorial_zones)
        TerritorialZone.zone_types.each_key do |zone_type|
          antenne_territorial_zones = territorial_zones.select { |tz| tz.zone_type == zone_type }
          next if antenne_territorial_zones.empty?
          attributes_table title: I18n.t(zone_type, scope: "activerecord.attributes.territorial_zone").pluralize do
            model = "DecoupageAdministratif::#{zone_type.camelize}".constantize
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
    end

    Arbre::Element.include TerritorialZonesHelper
  end
end
