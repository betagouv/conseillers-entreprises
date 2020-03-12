class AddPartnerTokenToInstitution < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :partner_token, :string
    add_index :institutions, :partner_token
  end
end
