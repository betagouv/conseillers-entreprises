module XlsxExport
  module AntenneStatsWorksheetGenerator
    class BySubject < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:antenne_subjects)

        needs_by_subjects = {}
        antenne_subjects_labels = @antenne.institution.subjects.map(&:label)

        @needs.map(&:subject).each do |subject|
          needs_by_subjects[subject.label] = @needs.where(subject: subject)
        end

        needs_by_antenne_subjects = needs_by_subjects.slice(*antenne_subjects_labels)
        needs_by_occasional_subjects = needs_by_subjects.except(*antenne_subjects_labels)

        generate_subjects_row(needs_by_antenne_subjects)

        if needs_by_occasional_subjects.any?
          sheet.add_row []
          sheet.add_row [
            I18n.t('antenne_stats_exporter.occasional_subjects'), '', '', '', '', ''
          ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]

          generate_subjects_row(needs_by_occasional_subjects)
        end

        finalise_agglomerate_style
      end

      private

      def generate_subjects_row(needs_by_subjects)
        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, subject_label, @antenne, ratio)
        end
      end
    end
  end
end
