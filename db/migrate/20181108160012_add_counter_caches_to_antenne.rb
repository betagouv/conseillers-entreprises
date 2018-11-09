class AddCounterCachesToAntenne < ActiveRecord::Migration[5.2]
  def up
    add_column :antennes, :experts_count, :integer
    add_column :antennes, :users_count, :integer
    Antenne.all.pluck(:id).each do |id|
      Antenne.reset_counters(id, :experts)
      Antenne.reset_counters(id, :users)
    end
  end

  def down
    remove_column :antennes, :experts_count
    remove_column :antennes, :users_count
  end
end
