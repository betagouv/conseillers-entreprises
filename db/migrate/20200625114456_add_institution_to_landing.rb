class AddInstitutionToLanding < ActiveRecord::Migration[6.0]
  def change
    add_reference :landings, :institution, foreign_key: true, index: true
    remove_column :institutions, :partner_token, :string
  end
end
