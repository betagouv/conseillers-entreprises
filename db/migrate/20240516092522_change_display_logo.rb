class ChangeDisplayLogo < ActiveRecord::Migration[7.0]
  def change
    rename_column :institutions, :display_logo, :display_logo_on_home_page
    add_column :institutions, :display_logo_in_partner_list, :boolean, default: true
  end
end
