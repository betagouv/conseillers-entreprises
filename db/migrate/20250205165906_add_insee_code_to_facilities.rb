class AddInseeCodeToFacilities < ActiveRecord::Migration[7.2]
  def change
    add_column :facilities, :insee_code, :string
    reversible do |dir|
      # rubocop:disable Rails/SquishedSQLHeredocs
      dir.up do
        execute <<-SQL
          UPDATE facilities
          SET insee_code = communes.insee_code
          FROM communes
          WHERE facilities.commune_id = communes.id
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE facilities
          SET commune_id = communes.id
          FROM communes
          WHERE facilities.insee_code = communes.insee_code
        SQL
      end
      # rubocop:enable Rails/SquishedSQLHeredocs
    end

    change_column_null :facilities, :insee_code, false
    remove_reference :facilities, :commune, index: true
  end
end
