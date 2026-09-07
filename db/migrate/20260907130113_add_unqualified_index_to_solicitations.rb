class AddUnqualifiedIndexToSolicitations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :solicitations, :id,
              where: "qualified IS NULL AND status = 3", # status_in_progress
              name: "index_solicitations_on_unqualified",
              algorithm: :concurrently
  end
end
