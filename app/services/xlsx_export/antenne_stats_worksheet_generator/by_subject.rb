module XlsxExport
  module AntenneStatsWorksheetGenerator
    class BySubject < Base
      include XlsxExport::AntenneStatsWorksheetGenerator::BySubjectMethods

      def generate
        sheet.add_row

        add_subject_table_header(:antenne_subjects)

        generate_by_subject_table(@needs)
      end
    end
  end
end
