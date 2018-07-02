class AddExpertRefToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :expert, foreign_key: true
  end
end
