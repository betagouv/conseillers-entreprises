module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByAntenne < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:antenne)

        needs_by_antennes = {}

        @antenne.territorial_antennes.each do |local_antenne|
          needs_by_antennes[local_antenne.name] = @needs.joins(:expert_antennes).where(antennes: { id: local_antenne.id })
        end

        needs_by_antennes.sort_by { |_, needs| -needs.count }.each do |antenne_name, needs|
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, antenne_name, ratio)
        end

        finalise_agglomerate_style
      end
    end
  end
end
