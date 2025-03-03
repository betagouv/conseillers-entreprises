module ActivityReports
  class Generate::AntenneMatches < Generate::Base
    private

    def generate_matches_files(quarter)
      return if reports.find_by(start_date: quarter.first).present?
      needs = @antenne.perimeter_received_needs.created_between(quarter.first, quarter.last)
      return if needs.blank?

      matches = Match.joins(:need).where(need: needs)
      return if matches.blank?

      # la tâche peut être longue, on la met dans une transaction pour garantir un état stable (pas de Matchreport sans fichier, par exemple)
      ActiveRecord::Base.transaction do
        result = matches.export_xlsx
        filename = I18n.t('activity_report_service.matches_file_name', number: TimeDurationService.find_quarter_for_month(quarter.first.month), year: quarter.first.year, antenne: @antenne.name.parameterize)
        report = reports.create!(start_date: quarter.first, end_date: quarter.last)
        report.file.attach(io: result.xlsx.to_stream(true),
                           key: "activity_report_matches/#{@antenne.name.parameterize}/#{filename}",
                           filename: filename,
                           content_type: 'application/xlsx')
      end
    end

    def last_periods
      last_quarters
    end

    def reports
      @antenne.matches_reports
    end
  end
end
