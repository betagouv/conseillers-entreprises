module XlsxExport
  module AntenneStatsWorksheetGenerator
    class National < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:subject)

        needs_by_subjects = {}
        @needs.map(&:subject).each do |subject|
          needs_by_subjects[subject.label] = @needs.where(subject: subject)
        end

        # Total
        add_agglomerate_rows(@needs, I18n.t('antenne_stats_exporter.total'), @antenne.institution)

        # By subject
        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, subject_label, @antenne.institution, ratio)
        end

        finalise_agglomerate_style
      end
    end
  end
end
