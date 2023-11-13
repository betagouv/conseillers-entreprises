module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByRegion < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:region)

        needs_by_territories = {}

        Territory.regions.each do |region|
          needs_by_territories[region.name] = @needs.by_region(region.id)
        end

        needs_by_territories.sort_by { |_, needs| -needs.count }.each do |region_name, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, region_name, @antenne, ratio)
        end

        finalise_agglomerate_style
      end
    end
  end
end
