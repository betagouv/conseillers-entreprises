module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByRefusedSubject < Base
      include XlsxExport::AntenneStatsWorksheetGenerator::BySubjectMethods

      def generate
        sheet.add_row [I18n.t('antenne_stats_exporter.quarter_stats_by_refused_subject')], style: @subtitle
        sheet.add_row

        sheet.add_row [
          I18n.t('antenne_stats_exporter.antenne_refused_subjects'),
          I18n.t('antenne_stats_exporter.refusals_count'),
          I18n.t('antenne_stats_exporter.needs_refused_percentage'),
        ], style: [@left_header, @right_header, @right_header]

        generate_by_subject_table(refused_needs)
      end

      private

      def refused_needs
        @refused_needs ||= @needs.joins(:matches).where(matches: { id: @antenne.perimeter_received_matches.ids, status: :not_for_me }).distinct
      end

      def current_needs
        @current_needs ||= @refused_needs
      end

      # Ici, on ne veut que 3 colonnes, d'où surcharge de la méthode
      def add_agglomerate_rows(needs, row_title, recipient, ratio = nil)
        sheet.add_row [
          row_title,
          needs.size,
          ratio,
        ], style: [nil, nil, @rate]
      end

      def add_subject_table_header(tab_scope)
        sheet.add_row [
          I18n.t(tab_scope, scope: ['antenne_stats_exporter']),
          I18n.t('antenne_stats_exporter.refusals_count'),
          I18n.t('antenne_stats_exporter.needs_refused_percentage'),
        ], style: [@left_header, @right_header, @right_header]
      end

      def finalise_agglomerate_style
        [
          'A1:C1',
          'A2:C2',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 70, 20, 25
      end
    end
  end
end
