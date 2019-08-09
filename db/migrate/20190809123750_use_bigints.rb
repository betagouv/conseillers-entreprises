class UseBigints < ActiveRecord::Migration[5.2]
  def up
    change_column :searches, :user_id, :bigint
  end

  def down
    change_column :searches, :user_id, :integer
  end
end
