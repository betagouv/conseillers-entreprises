class AddInseeCodeToFacilities < ActiveRecord::Migration[7.2]
  def change
    add_column :facilities, :insee_code, :string
    reversible do |dir|
      dir.up do
        bar = ProgressBar.new(Facility.count)
        Facility.find_each do |facility|
          facility.update_columns(insee_code: facility.commune.insee_code)
          bar.increment!
        end
      end

      dir.down do
        Facility.find_each do |facility|
          commune = Commune.find_by(insee_code: facility.insee_code)
          facility.update_columns(commune: commune)
        end
      end
    end

    change_column_null :facilities, :insee_code, false
    remove_reference :facilities, :commune, index: true
  end
end
