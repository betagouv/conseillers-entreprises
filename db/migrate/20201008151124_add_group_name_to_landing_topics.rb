class AddGroupNameToLandingTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :landing_topics, :group_name, :string
  end
end
