module XlsxExport
  module AntenneStatsWorksheetGenerator
    class BySubject < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:antenne_subjects)

        generate_by_subjects_stats(@needs)
      end
    end
  end
end
