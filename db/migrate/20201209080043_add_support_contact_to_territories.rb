class AddSupportContactToTerritories < ActiveRecord::Migration[6.0]
  def change
    add_reference :territories, :support_contact, index: true
  end
end
