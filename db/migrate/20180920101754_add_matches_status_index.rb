class AddMatchesStatusIndex < ActiveRecord::Migration[5.2]
  def change
    add_index(:matches, :status)
  end
end
