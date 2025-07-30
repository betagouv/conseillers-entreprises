module XlsxExport
  module AntenneStatsWorksheetGenerator
    module ByAntenneMethods
      def generate_by_antenne_table(territorial_antennes = @antenne.territorial_antennes)
        add_agglomerate_headers(:antenne)

        # Chiffres de référence - antenne régionale
        matches = @antenne.perimeter_received_matches_from_needs(@needs)
        positionning_size = calculate_positionning_status_size(:positionning, matches)
        @rate_positionning = calculate_rate(positionning_size, matches)

        positionning_accepted_size = calculate_positionning_status_size(:positionning_accepted, matches)
        @rate_positionning_accepted = calculate_rate(positionning_accepted_size, matches)

        done_size = calculate_positionning_status_size(:done, matches)
        @rate_done = calculate_rate(done_size, matches)

        sheet.add_row [
          @antenne.name,
          @needs.size,
          calculate_rate(@needs.count, @needs),
          @rate_positionning,
          @rate_positionning_accepted,
          @rate_done,
        ], style: [nil, nil, @rate, @rate, @rate, @rate]

        # Chiffres des antennes locales
        needs_by_antennes = {}

        territorial_antennes.each do |local_antenne|
          needs_by_antennes[local_antenne.name] = @needs.joins(:expert_antennes).where(antennes: { id: local_antenne.id }).distinct
        end

        needs_by_antennes.sort_by { |_, needs| -needs.count }.each do |antenne_name, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, antenne_name, @antenne, ratio)
        end
      end

      def finalise_by_antenne_calculation_style(start_row = 5, territorial_antennes_count = @antenne.territorial_antennes.count)
        # highlight positionning
        last_row = territorial_antennes_count + (start_row - 1)
        sheet.add_conditional_formatting("D#{start_row}:D#{last_row}",
          type: :cellIs,
          operator: :lessThan,
          formula: format_rate_for_print(@rate_positionning),
          dxfId: @blue_bg,
          priority: 1)
        # highlight positionning_accepted
        sheet.add_conditional_formatting("E#{start_row}:E#{last_row}",
          type: :cellIs,
          operator: :lessThan,
          formula: format_rate_for_print(@rate_positionning_accepted),
          dxfId: @blue_bg,
          priority: 1)
        # highlight done
        sheet.add_conditional_formatting("F#{start_row}:F#{last_row}",
          type: :cellIs,
          operator: :lessThan,
          formula: format_rate_for_print(@rate_done),
          dxfId: @blue_bg,
          priority: 1)
      end

      def format_rate_for_print(rate)
        "%.1f%%" % (100 * rate)
      end
    end
  end
end
