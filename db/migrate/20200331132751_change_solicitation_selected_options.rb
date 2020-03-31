class ChangeSolicitationSelectedOptions < ActiveRecord::Migration[6.0]
  def change
    rename_column :solicitations, :slug, :landing_slug
    change_column_null :solicitations, :landing_slug, false

    add_column :solicitations, :landing_options_slugs, :string, array: true
    rename_column :solicitations, :options, :options_deprecated

    up_only do
      Solicitation.find_each do |s|
        s.update(landing_options_slugs: s.options_deprecated.select{ |_, v| v.to_bool }.keys.map{ |o| o.parameterize.underscore })
      end
    end
  end
end
