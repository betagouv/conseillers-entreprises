class AddAbsenceEndAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :absence_start_at, :datetime
    add_column :users, :absence_end_at, :datetime
  end
end
