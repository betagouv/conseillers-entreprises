module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByRefusedSubject < Base
      def generate
        sheet.add_row [I18n.t('antenne_stats_exporter.quarter_stats_by_refused_subject')], style: @subtitle
        sheet.add_row

        sheet.add_row [
          I18n.t('antenne_stats_exporter.antenne_subjects'),
          I18n.t('antenne_stats_exporter.refusals_count'),
          I18n.t('antenne_stats_exporter.needs_percentage'),
        ], style: [@left_header, @right_header, @right_header]

        generate_by_subjects_stats(refused_needs)
      end

      private

      def refused_needs
        @refused_needs ||= @needs.joins(:matches).where(matches: { id: @antenne.perimeter_received_matches.ids, status: :not_for_me })
      end

      def add_agglomerate_rows(needs, row_title, recipient, ratio = nil)
        sheet.add_row [
          row_title,
          needs.size,
          ratio,
        ], style: [nil, nil, @rate]
      end

      def finalise_agglomerate_style
        [
          'A1:F1',
          'A2:F2',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 50, 15, 25
      end
    end
  end
end
