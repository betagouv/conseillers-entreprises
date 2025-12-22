module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByTerritory < Base
      include XlsxExport::AntenneStatsWorksheetGenerator::ByAntenneMethods

      def generate
        sheet.add_row

        ## Par territoire
        #
        add_agglomerate_headers(:region)

        # Chiffres de référence - antenne régionale
        matches = @antenne.perimeter_received_matches_from_needs(@needs)
        positionning_size = calculate_positionning_status_size(:positionning, matches)
        @rate_positionning = calculate_rate(positionning_size, matches)

        positionning_accepted_size = calculate_positionning_status_size(:positionning_accepted, matches)
        @rate_positionning_accepted = calculate_rate(positionning_accepted_size, matches)

        done_size = calculate_positionning_status_size(:done, matches)
        @rate_done = calculate_rate(done_size, matches)

        sheet.add_row [
          I18n.t('antenne_stats_exporter.national'),
          @needs.size,
          calculate_rate(@needs.count, @needs),
          @rate_positionning,
          @rate_positionning_accepted,
          @rate_done,
        ], style: [nil, nil, @rate, @rate, @rate, @rate]

        # Chiffres des antennes locales
        needs_by_territories = {}

        RegionOrderingService.call.each do |region|
          needs_by_territories[region.nom] = @needs.by_region(region.code).distinct
        end

        needs_by_territories.sort_by { |_, needs| -needs.count }.each do |region_name, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, region_name, @antenne, ratio)
        end

        finalise_by_territory_calculation_style(5)

        ## Par antennes
        #
        sheet.add_row

        territorial_antennes = @antenne.territorial_antennes.joins(:received_needs).where(received_needs: { id: @needs.pluck(:id) }).distinct
        generate_by_antenne_table(territorial_antennes)

        sheet.add_row
        sheet.add_row [I18n.t('antenne_stats_exporter.no_antennes_without_needs')], style: [@italic]

        regions_count = RegionOrderingService.call.count
        antennes_start_row = 5 + regions_count + 3
        finalise_by_antenne_calculation_style(antennes_start_row, territorial_antennes.count)

        finalise_agglomerate_style
      end

      private

      def finalise_by_territory_calculation_style(start_row = 5)
        # highlight positionning (D), positionning_accepted (E), done (F).
        regions_count = RegionOrderingService.call.count
        last_row = regions_count + (start_row - 1)
        sheet.add_conditional_formatting("D#{start_row}:F#{last_row}",
          type: :cellIs,
          operator: :lessThan,
          formula: "D$#{start_row - 1}", # The cell of @rate_positioning; the column is relative, the row is absolute.
          dxfId: @pink_bg,
          priority: 1)
      end
    end
  end
end
