class RemoveRequiresFields < ActiveRecord::Migration[7.2]
  def change
    create_enum :landing_subject_fields_mode, [:siret, :location]
    add_column :landing_subjects, :fields_mode, :landing_subject_fields_mode

    reversible do |dir|
       dir.up do
         LandingSubject.where(requires_location: true, requires_siret: false).update_all(fields_mode: :location)
         LandingSubject.where(requires_location: false, requires_siret: true).update_all(fields_mode: :siret)
         raise "Unexpected LandingSubject values" if LandingSubject.exists?(fields_mode: nil)
       end
       dir.down do
         LandingSubject.where(fields_mode: :location).update_all(requires_location: true, requires_siret: false)
         LandingSubject.where(fields_mode: :siret).update_all(requires_location: false, requires_siret: true)
       end
     end

    change_column_null :landing_subjects, :fields_mode, false

    remove_column :landing_subjects, :requires_siret, :boolean, null: false, default: true
    remove_column :landing_subjects, :requires_location, :boolean, null: false, default: false
    remove_column :landing_subjects, :requires_requested_help_amount, :boolean, null: false, default: false
  end
end
