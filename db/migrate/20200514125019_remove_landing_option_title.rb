class RemoveLandingOptionTitle < ActiveRecord::Migration[6.0]
  def change
    remove_column :landing_options, :title, :string
  end
end
