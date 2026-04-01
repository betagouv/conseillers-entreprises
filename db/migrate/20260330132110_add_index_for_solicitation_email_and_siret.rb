class AddIndexForSolicitationEmailAndSiret < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def change
    add_index :solicitations, :siret, algorithm: :concurrently, if_not_exists: true
    add_index :solicitations, :email, algorithm: :concurrently, if_not_exists: true
  end
end
