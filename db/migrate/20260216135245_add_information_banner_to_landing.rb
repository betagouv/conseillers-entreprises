class AddInformationBannerToLanding < ActiveRecord::Migration[7.2]
  def change
    add_column :landings, :information_banner, :text
  end
end
