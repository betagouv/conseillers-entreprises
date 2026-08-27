module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      include XlsxExport::AntenneStatsWorksheetGenerator::ByAntenneMethods

      def generate
        sheet.add_row
        generate_by_antenne_table
        finalise_agglomerate_style(with_response_time: true)
        finalise_by_antenne_calculation_style
      end
    end
  end
end
