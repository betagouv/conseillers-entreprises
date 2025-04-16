module ActivityReports
  class Generate::AntenneMatches < Generate::Base
    private

    def generate_files(quarter)
      needs = antenne.perimeter_received_needs.created_between(quarter.first, quarter.last)
      return if needs.blank?

      matches = Match.joins(:need).where(need: needs)
      return if matches.blank?

      # la tâche peut être longue, on la met dans une transaction pour garantir un état stable (pas de Matchreport sans fichier, par exemple)
      ActiveRecord::Base.transaction do
        result = matches.export_xlsx
        create_file(result, quarter)
      end
    end

    def antenne
      @item
    end

    def last_periods
      last_quarters
    end

    def report_type
      :matches
    end

    def reports
      antenne.matches_reports
    end
  end
end
