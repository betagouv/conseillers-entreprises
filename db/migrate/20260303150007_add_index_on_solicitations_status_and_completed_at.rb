class AddIndexOnSolicitationsStatusAndCompletedAt < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :solicitations, [:status, :completed_at], algorithm: :concurrently
  end
end
