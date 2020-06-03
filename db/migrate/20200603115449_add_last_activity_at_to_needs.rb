class AddLastActivityAtToNeeds < ActiveRecord::Migration[6.0]
  def up
    add_column :needs, :last_activity_at, :timestamp, default: -> { 'NOW()' }, null: false

    Need.all.each do |need|
      last_activity = need.matches.pluck(:updated_at).max || need.updated_at
      need.update(last_activity_at: last_activity)
    end
  end

  def down
    remove_column :needs, :last_activity_at
  end
end
