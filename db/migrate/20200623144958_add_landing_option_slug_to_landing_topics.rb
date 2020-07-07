class AddLandingOptionSlugToLandingTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :landing_topics, :landing_option_slug, :string
  end
end
