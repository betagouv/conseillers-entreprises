class QuarterlyReportService
  class << self
    def generate_reports(antennes = Antenne.all)
      antennes.each do |antenne|
        quarters = last_quarters(antenne)
        next if quarters.nil?

        quarters.each do |quarter|
          check_matches_file(antenne, quarter)
          check_stats_file(antenne, quarter)
        end
        destroy_old_report_files(antenne, quarters)
      end
    end

    def send_emails
      User.managers.each do |user|
        next unless user.managed_antennes.map { |antenne| antenne.quarterly_reports.find_by(start_date: 3.months.ago.beginning_of_month) }.any?
        UserMailer.quarterly_report(user).deliver_later
      end
    end

    private

    def check_matches_file(antenne, quarter)
      matches_report = antenne.matches_reports.find_by(start_date: quarter.first)
      begin
        if matches_report.present?
          matches_report.file.download
        else
          generate_matches_files(antenne, quarter)
        end
      rescue
        matches_report.destroy
        generate_matches_files(antenne, quarter)
      end
    end

    def check_stats_file(antenne, quarter)
      stats_report = antenne.stats_reports.find_by(start_date: quarter.first)
      begin
        if stats_report.present?
          stats_report.file.download
        else
          generate_stats_files(antenne, quarter)
        end
      rescue
        stats_report.destroy
        generate_stats_files(antenne, quarter)
      end
    end

    def generate_matches_files(antenne, quarter)
      needs = antenne.perimeter_received_needs.created_between(quarter.first, quarter.last)
      return if needs.blank?

      matches = Match.joins(:need).where(need: needs)
      return if matches.blank?

      result = matches.export_xlsx
      filename = I18n.t('quarterly_report_service.matches_file_name', number: TimeDurationService.find_quarter(quarter.first.month), year: quarter.first.year, antenne: antenne.name.parameterize)
      antenne.matches_reports.create(start_date: quarter.first, end_date: quarter.last)
        .file.attach(io: result.xlsx.to_stream(true),
                     key: "quarterly_report_matches/#{antenne.name.parameterize}/#{filename}",
                     filename: filename,
                     content_type: 'application/xlsx')
    end

    def generate_stats_files(antenne, quarter)
      exporter = XlsxExport::AntenneStatsExporter.new({
        start_date: quarter.first,
            end_date: quarter.last,
            antenne: antenne
      })
      result = exporter.export

      filename = I18n.t('quarterly_report_service.stats_file_name', number: TimeDurationService.find_quarter(quarter.first.month), year: quarter.first.year, antenne: antenne.name.parameterize)
      antenne.stats_reports.create(start_date: quarter.first, end_date: quarter.last)
        .file.attach(io: result.xlsx.to_stream(true),
                     key: "quarterly_report_stats/#{antenne.name.parameterize}/#{filename}",
                     filename: filename,
                     content_type: 'application/xlsx')
    end

    def destroy_old_report_files(antenne, quarters)
      start_dates = quarters.map(&:first)
      antenne.quarterly_reports.where.not(start_date: start_dates).destroy_all
    end

    def last_quarters(antenne)
      return if antenne.perimeter_received_needs.blank?
      first_need_date = antenne.perimeter_received_needs.minimum(:created_at).to_date
      quarters = TimeDurationService.past_year_quarters
      quarters.reject! { |range| first_need_date > range.last }
      quarters
    end
  end
end
