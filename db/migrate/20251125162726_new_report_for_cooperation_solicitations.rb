class NewReportForCooperationSolicitations < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :activity_reports_categories, 'solicitations'
    add_column :cooperations, :wants_solicitations_export, :boolean, default: false, null: false
  end
end
