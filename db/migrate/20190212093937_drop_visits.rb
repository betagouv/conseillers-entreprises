class DropVisits < ActiveRecord::Migration[5.2]
  def change
    remove_column :diagnoses, :visit_id
    drop_table :visits
  end
end
