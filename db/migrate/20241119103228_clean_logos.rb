class CleanLogos < ActiveRecord::Migration[7.0]
  def up
    remove_column :landing_subjects, :display_region_logo, :boolean, default: false
    remove_column :landings, :main_logo, :string
    add_reference :logos, :logoable, polymorphic: true, index: true

    Logo.find_each do |logo|
      logo.update(logoable_id: logo.institution_id, logoable_type: 'Institution') if logo.institution_id.present?
    end
    remove_column :logos, :institution_id, :bigint
  end

  def down
    add_reference :logos, :institution
    Logo.find_each do |logo|
      logo.update(institution_id: logo.logoable_id) if Institution.find(logo.logoable_id).present?
    end
    remove_reference :logos, :logoable, polymorphic: true, index: true
    add_column :landing_subjects, :display_region_logo, :boolean, default: false
    add_column :landings, :main_logo, :string
  end
end
