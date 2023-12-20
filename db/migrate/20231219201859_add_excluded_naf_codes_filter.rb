class AddExcludedNafCodesFilter < ActiveRecord::Migration[7.0]
  def change
    add_column :match_filters, :excluded_naf_codes, :string, array: true
  end
end
