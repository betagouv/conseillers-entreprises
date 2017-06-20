# frozen_string_literal: true

class AddRegionalFieldsToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_column :assistances, :county, :integer
    add_column :assistances, :geographic_scope, :integer
  end
end
