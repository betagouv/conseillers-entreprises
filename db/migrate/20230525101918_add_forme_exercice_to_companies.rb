class AddFormeExerciceToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :forme_exercice, :string
    add_column :companies, :activite_liberale, :boolean, default: false
  end
end
