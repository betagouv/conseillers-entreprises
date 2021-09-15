class AddDisplayPartnershipIframe < ActiveRecord::Migration[6.1]
  def change
    add_column :landings, :display_pde_partnership_mention, :boolean, default: false
  end
end
