class AddMaxYearsToMatchFilters < ActiveRecord::Migration[6.1]
  def change
    add_column :match_filters, :max_years_of_existence, :integer
  end
end
