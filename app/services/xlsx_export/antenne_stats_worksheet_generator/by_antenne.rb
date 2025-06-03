module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      def generate
        sheet.add_row

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

        @antenne.territorial_antennes.each do |local_antenne|
          needs_by_antennes[local_antenne.name] = @needs.joins(:expert_antennes).where(antennes: { id: local_antenne.id })
        end

        needs_by_antennes.sort_by { |_, needs| -needs.count }.each do |antenne_name, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, antenne_name, @antenne, ratio)
        end

        finalise_agglomerate_style
        finalise_calculation_style
      end

      def finalise_calculation_style
        # highlight positionning
        last_cell_number = @antenne.territorial_antennes.count + 4
        sheet.add_conditional_formatting("D5:D#{last_cell_number}",
          type: :cellIs,
          operator: :lessThanOrEqual,
          formula: format_rate_for_print(@rate_positionning),
          dxfId: @blue_bg,
          priority: 1)
        # highlight positionning_accepted
        sheet.add_conditional_formatting("E5:E#{last_cell_number}",
          type: :cellIs,
          operator: :lessThanOrEqual,
          formula: format_rate_for_print(@rate_positionning_accepted),
          dxfId: @blue_bg,
          priority: 1)
        # highlight done
        sheet.add_conditional_formatting("F5:F#{last_cell_number}",
          type: :cellIs,
          operator: :lessThanOrEqual,
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
