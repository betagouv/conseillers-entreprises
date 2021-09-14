class CreateLogos < ActiveRecord::Migration[6.1]
  def change
    create_table :logos do |t|
      t.string :slug
      t.string :name

      t.timestamps
    end

    create_table :landing_subjects_logos do |t|
      t.belongs_to :logo
      t.belongs_to :landing_subject
    end

    up_only do
      LandingTheme.find_each do |theme|
        next if theme.logos.blank?
        slugs = theme.logos.split(",")
        slugs.each do |slug|
          logo = Logo.find_or_create_by!(slug: slug.strip)
          logo.update(name: slug.strip.tr('-', ' ').capitalize)
          theme.landing_subjects.each { |subject| subject.logos << logo }
        end
      end
    end

    remove_column :landing_themes, :logos, :string
    add_column :landing_subjects, :display_region_logo, :boolean, default: false
  end
end
