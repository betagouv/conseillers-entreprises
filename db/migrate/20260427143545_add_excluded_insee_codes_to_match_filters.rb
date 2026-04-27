class AddExcludedInseeCodesToMatchFilters < ActiveRecord::Migration[8.1]
  def change
    add_column :match_filters, :excluded_insee_codes, :string, array: true, default: []
  end
end
