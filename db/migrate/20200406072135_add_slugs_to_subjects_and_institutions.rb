class AddSlugsToSubjectsAndInstitutions < ActiveRecord::Migration[6.0]
  def change
    change_column_null :themes, :label, false
    change_column_null :subjects, :label, false
    change_column_null :institutions, :name, false

    add_column :subjects, :slug, :string
    add_index :subjects, :slug, unique: true
    add_column :institutions, :slug, :string
    add_index :institutions, :slug, unique: true

    up_only do
      Subject.all.each do |subject|
        subject.compute_slug && subject.save!
      end
      Institution.all.each do |institution|
        institution.compute_slug && institution.save!
      end
    end

    change_column_null :subjects, :slug, false
    change_column_null :institutions, :slug, false
  end
end
