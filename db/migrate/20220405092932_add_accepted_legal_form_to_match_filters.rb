class AddAcceptedLegalFormToMatchFilters < ActiveRecord::Migration[6.1]
  def change
    add_column :match_filters, :accepted_legal_forms, :string, array: true
  end
end
