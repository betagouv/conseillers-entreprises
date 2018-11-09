class AddAntennesCountToInstitution < ActiveRecord::Migration[5.2]
  def up
    add_column :institutions, :antennes_count, :integer
    Institution.all.pluck(:id).each do |id|
      Institution.reset_counters(id, :antennes)
    end
  end

  def down
    remove_column :institutions, :antennes_count
  end
end
