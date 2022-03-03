class AddCategoryToQuarterlyReports < ActiveRecord::Migration[6.1]
  def change
    create_enum "quarterly_reports_categories", %w[matches stats]
    add_column :quarterly_reports, :category, :quarterly_reports_categories
    add_index :quarterly_reports, :category
  end
end
