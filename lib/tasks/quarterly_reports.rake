task quarterly_reports: :environment do
  QuarterlyReportService.matches_export
end
