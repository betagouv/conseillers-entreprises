module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      def generate
        sheet.add_row

        sheet.add_row [
          I18n.t('antenne_stats_exporter.antenne'),
          I18n.t('antenne_stats_exporter.needs_count'),
          I18n.t('antenne_stats_exporter.positionning_rate'),
          I18n.t('antenne_stats_exporter.positionning_accepted_rate')
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header]

        @antenne.territorial_antennes.each do |antenne|
          needs = @needs.joins(:expert_antennes).where(antennes: { id: antenne.id })
          matches = @antenne.perimeter_received_matches_from_needs(needs)
          positionning_size = calculate_positionning_status_size(:positionning, matches)
          positionning_accepted_size = calculate_positionning_status_size(:positionning_accepted, matches)
          sheet.add_row [
            antenne.name,
            needs.size,
            calculate_rate(positionning_size, matches),
            calculate_rate(positionning_accepted_size, matches),
          ], style: [nil, nil, @rate, @rate]
        end

        finalise_style
      end

      # Style
      #
      def finalise_style
        [
          'A1:G1',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 18, 22, 22
      end
    end
  end
end
