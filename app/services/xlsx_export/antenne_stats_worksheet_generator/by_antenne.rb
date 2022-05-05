module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      def generate
        sheet.add_row

        add_agglomerate_headers

        @antenne.territorial_antennes.each do |local_antenne|
          needs = @needs.joins(:expert_antennes).where(antennes: { id: local_antenne.id })
          add_agglomerate_rows(needs, local_antenne.name)
        end

        finalise_agglomerate_style
      end
    end
  end
end
