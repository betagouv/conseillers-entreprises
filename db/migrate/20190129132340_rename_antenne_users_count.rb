class RenameAntenneUsersCount < ActiveRecord::Migration[5.2]
  def up
    rename_column :antennes, :users_count, :advisors_count

    Antenne.all.pluck(:id).each do |id|
      Antenne.reset_counters(id, :advisors)
    end
  end

  def down
    rename_column :antennes, :advisors_count, :users_count
  end
end
