class CreateExpertsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :experts_users, id: false do |t|
      t.belongs_to :expert, index: true
      t.belongs_to :user, index: true
    end
    remove_reference :users, :expert, foreign_key: true
  end
end
