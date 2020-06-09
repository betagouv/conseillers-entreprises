class RemoveSolicitationOptionsDeprecated < ActiveRecord::Migration[6.0]
  def change
    # followup #977
    # it used to be called :needs, then :options… Now we’re using :landing_options_slugs, an array, instead of this json.
    remove_column :solicitations, :options_deprecated, :jsonb, default: {}
  end
end
