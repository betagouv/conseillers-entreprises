module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:antenne)

        @antenne.territorial_antennes.each do |local_antenne|
          needs = @needs.joins(:expert_antennes).where(antennes: { id: local_antenne.id })
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, ratio, local_antenne.name)
        end

        finalise_agglomerate_style
      end
    end
  end
end
