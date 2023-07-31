module XlsxExport
  module AntenneStatsWorksheetGenerator
    class BySubject < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:subject)

        needs_by_subjects = {}

        @antenne.institution.subjects.each do |subject|
          needs_by_subjects[subject.label] = @needs.where(subject: subject)
        end

        needs_by_subjects.sort_by { |_, needs| -needs.count }.each do |subject_label, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, subject_label, ratio)
        end

        finalise_agglomerate_style
      end
    end
  end
end
