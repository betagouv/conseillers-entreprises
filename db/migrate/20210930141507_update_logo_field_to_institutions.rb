class UpdateLogoFieldToInstitutions < ActiveRecord::Migration[6.1]
  def up
    add_column :institutions, :display_logo, :boolean, default: false
    Institution.where.not(logo_sort_order: nil).each { |institution| institution.update(display_logo: true) }
    remove_column :institutions, :logo_sort_order
  end

  def down
    add_column :institutions, :logo_sort_order, :integer
    Institution.where(display_logo: true).each { |institution| institution.update(logo_sort_order: 1) }
    remove_column :institutions, :display_logo
  end
end
