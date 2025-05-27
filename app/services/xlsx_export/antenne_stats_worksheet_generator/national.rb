module XlsxExport
  module AntenneStatsWorksheetGenerator
    class National < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:institution_subjects)

        needs_by_subjects = {}
        subjects_labels = @antenne.institution.subjects.map(&:label)

        @needs.map(&:subject).each do |subject|
          needs_by_subjects[subject.label] = @needs.where(subject: subject)
        end

        needs_by_institution_subjects = needs_by_subjects.slice(*subjects_labels)
        needs_by_occasional_subjects = needs_by_subjects.except(*subjects_labels)

        # Total
        add_agglomerate_rows(@needs, I18n.t('antenne_stats_exporter.total'), @antenne.institution)

        generate_subjects_row(needs_by_institution_subjects, @antenne.institution)

        if needs_by_occasional_subjects.any?
          sheet.add_row []
          sheet.add_row [
            I18n.t('antenne_stats_exporter.occasional_subjects'), '', '', '', '', ''
          ], style: [@left_header, @right_header, @right_header, @right_header, @right_header, @right_header]

          generate_subjects_row(needs_by_occasional_subjects, @antenne.institution)
        end

        finalise_agglomerate_style
      end
    end
  end
end
