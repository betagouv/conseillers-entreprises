task test_task: :environment do
  a = Antenne.find 840
  a.quarterly_reports.destroy_all
  sleep 5
  QuarterlyReportService.new(a).call
end
