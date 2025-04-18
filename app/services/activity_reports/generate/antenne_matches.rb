module ActivityReports
  class Generate::AntenneMatches < Generate::Base
    private

    def generate_files(period)
      needs = antenne.perimeter_received_needs.created_between(period.first, period.last)
      return if needs.blank?

      matches = Match.joins(:need).where(need: needs)
      return if matches.blank?

      # la tâche peut être longue, on la met dans une transaction pour garantir un état stable (pas de Matchreport sans fichier, par exemple)
      ActiveRecord::Base.transaction do
        result = matches.export_xlsx
        create_file(result, period)
      end
    end

    def antenne
      @item
    end

    def report_type
      :matches
    end

    def reports
      antenne.matches_reports
    end

    def find_last_year_periods
      TimeDurationService.past_year_months
    end

    def build_filename(period)
      I18n.t("activity_report_service.#{report_type}_file_name", month: period.first.month, year: period.first.year, item: @item.name.parameterize)
    end
  end
end
