module XlsxExport
  module AntenneStatsWorksheetGenerator
    module BySubjectMethods
      # Pages par sujet
      #
      def generate_by_subject_table(needs)
        needs_by_subjects = {}
        antenne_subjects_labels = @antenne.institution.subjects.map(&:label)

        needs.map(&:subject).each do |subject|
          needs_by_subjects[subject.label] = needs.where(subject: subject)
        end

        needs_by_antenne_subjects = needs_by_subjects.slice(*antenne_subjects_labels)
        needs_by_occasional_subjects = needs_by_subjects.except(*antenne_subjects_labels)

        generate_subjects_row(needs_by_antenne_subjects)

        if needs_by_occasional_subjects.any?
          sheet.add_row []
          add_subject_table_header(:occasional_subjects)

          generate_subjects_row(needs_by_occasional_subjects)
        end

        finalise_agglomerate_style
      end

      def generate_subjects_row(needs_by_subjects, recipient = @antenne)
        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          ratio = calculate_rate(needs.count, current_needs)
          add_agglomerate_rows(needs, subject_label, recipient, ratio)
        end
      end

      def add_subject_table_header(tab_scope)
        sheet.add_row [
          I18n.t(tab_scope, scope: ['antenne_stats_exporter']),
          I18n.t('antenne_stats_exporter.needs_count'),
          I18n.t('antenne_stats_exporter.needs_percentage'),
          I18n.t('antenne_stats_exporter.positionning_rate'),
          I18n.t('antenne_stats_exporter.positionning_accepted_rate'),
          I18n.t('antenne_stats_exporter.done_rate')
        ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]
      end
    end
  end
end
