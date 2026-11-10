class AddReservesInstitutionExpertsToCooperations < ActiveRecord::Migration[8.1]
  def change
    add_column :cooperations, :reserves_institution_experts, :boolean, default: false, null: false
  end
end
