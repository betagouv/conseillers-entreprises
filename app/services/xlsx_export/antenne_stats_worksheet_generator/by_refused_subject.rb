module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByRefusedSubject < Base
      include XlsxExport::AntenneStatsWorksheetGenerator::BySubjectMethods

      def generate
        sheet.add_row [I18n.t('antenne_stats_exporter.quarter_stats_by_refused_subject')], style: @subtitle
        sheet.add_row

        sheet.add_row [
          I18n.t('antenne_stats_exporter.antenne_refused_subjects'),
          I18n.t('antenne_stats_exporter.needs_count_on_subject'),
          I18n.t('antenne_stats_exporter.refusals_count'),
          I18n.t('antenne_stats_exporter.refusal_rate_on_subject'),
          I18n.t('antenne_stats_exporter.needs_refused_percentage'),
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header]

        generate_by_subject_table(refused_needs)
      end

      private

      def refused_needs
        @refused_needs ||= @needs.joins(:matches).where(matches: { id: @antenne.perimeter_received_matches.ids, status: :not_for_me }).distinct
      end

      def current_needs
        @current_needs ||= @refused_needs
      end

      def generate_subjects_row(needs_by_subjects, recipient = @antenne)
        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          all_needs_on_subject = @needs.where(subject: needs.first.subject)
          refused_rate_on_subject = calculate_rate(needs.count, all_needs_on_subject)
          ratio = calculate_rate(needs.count, current_needs)
          add_agglomerate_rows(needs, subject_label, recipient, all_needs_on_subject.size, refused_rate_on_subject, ratio)
        end
      end

      def add_agglomerate_rows(needs, row_title, recipient, all_needs_on_subject_size, refused_rate_on_subject, ratio = nil)
        sheet.add_row [
          row_title,
          all_needs_on_subject_size,
          needs.size,
          refused_rate_on_subject,
          ratio,
        ], style: [nil, nil, nil, @rate, @rate]
      end

      def add_subject_table_header(tab_scope)
        sheet.add_row [
          I18n.t(tab_scope, scope: ['antenne_stats_exporter']),
          I18n.t('antenne_stats_exporter.needs_count_on_subject'),
          I18n.t('antenne_stats_exporter.refusals_count'),
          I18n.t('antenne_stats_exporter.refusal_rate_on_subject'),
          I18n.t('antenne_stats_exporter.needs_refused_percentage'),
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header]
      end

      def finalise_agglomerate_style
        [
          'A1:E1',
          'A2:E2',
        ].each { |range| sheet.merge_cells(range) }

        sheet.column_widths 70, 20, 20, 20, 25
      end
    end
  end
end
