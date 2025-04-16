class ChangeQuarterlyReportToActivityReport < ActiveRecord::Migration[7.2]
  def up
    rename_table :quarterly_reports, :activity_reports
    add_reference :activity_reports, :reportable, polymorphic: true, index: true

    rename_enum :quarterly_reports_categories, :activity_reports_categories
    add_enum_value :activity_reports_categories, "cooperation"

    ActivityReport.where.not(antenne_id: nil).find_each do |report|
      report.update(reportable_id: report.antenne_id, reportable_type: 'Antenne')
    end

    remove_reference :activity_reports, :antenne
  end

  def down
    add_reference :activity_reports, :antenne, index: true

    ActivityReport.where(reportable_type: 'Antenne').find_each do |report|
      report.update(antenne_id: report.reportable_id)
    end

    rename_enum :activity_reports_categories, :quarterly_reports_categories

    remove_reference :activity_reports, :reportable, polymorphic: true
    rename_table :activity_reports, :quarterly_reports
  end
end
