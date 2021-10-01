class AddInstitutionToLogos < ActiveRecord::Migration[6.1]
  def up
    add_reference :logos, :institution, foreign_key: true, null: true
    rename_column :logos, :slug, :filename

    Logo.all.each do |logo|
      institution = Institution.find_by(slug: logo.filename)
      logo.update(institution_id: institution.id) if institution.present?
    end
  end

  def down
    remove_reference :logos, :institution, foreign_key: true, null: true
    rename_column :logos, :filename, :slug
  end
end
