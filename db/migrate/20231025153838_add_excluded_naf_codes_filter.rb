class AddExcludedNafCodesFilter < ActiveRecord::Migration[7.0]
  def change
    add_column :match_filters, :excluded_legal_forms, :string, array: true
  end
end
