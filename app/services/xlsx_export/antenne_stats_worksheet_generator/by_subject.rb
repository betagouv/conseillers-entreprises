module XlsxExport
  module AntenneStatsWorksheetGenerator
    class BySubject < Base
      def generate
        sheet.add_row

        add_agglomerate_headers

        @antenne.institution.subjects.each do |subject|
          needs = @needs.where(subject: subject)
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, ratio, subject.label)
        end

        finalise_agglomerate_style
      end
    end
  end
end
