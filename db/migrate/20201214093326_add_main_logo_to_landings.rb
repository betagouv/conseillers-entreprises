class AddMainLogoToLandings < ActiveRecord::Migration[6.0]
  def change
    add_column :landings, :main_logo, :string
    up_only do
      Landing.find_by(slug: 'relance').update(main_logo: "logo-france-relance")
    end
  end
end
