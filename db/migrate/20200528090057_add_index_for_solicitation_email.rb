class AddIndexForSolicitationEmail < ActiveRecord::Migration[6.0]
  def change
    add_index :solicitations, :email
  end
end
