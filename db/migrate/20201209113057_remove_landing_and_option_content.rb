class RemoveLandingAndOptionContent < ActiveRecord::Migration[6.0]
  def change
    remove_column :landings, :content, :jsonb, default: {}
    remove_column :landing_options, :content, :jsonb, default: {}
  end
end
