class ChangeLandingOptionSlugToTitle < ActiveRecord::Migration[6.0]
  def change
    rename_column :landing_options, :slug, :title
    add_column :landing_options, :slug, :string

    up_only do
      LandingOption.all.each do |option|
        option.update(slug: option.title.parameterize.underscore)
      end
    end

    change_column_null :landing_options, :slug, false
  end
end
