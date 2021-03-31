class RemoveColumnsAudits < ActiveRecord::Migration[6.0]
  def change
    drop_table :audits
  end
end
