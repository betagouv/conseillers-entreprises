# frozen_string_literal: true

class RemoveGeographicAndInstitutionDataFromAssistance < ActiveRecord::Migration[5.1]
  def change
    remove_column :assistances, :county, :integer
    remove_column :assistances, :geographic_scope, :integer
    remove_reference :assistances, :institution, foreign_key: true
  end
end
