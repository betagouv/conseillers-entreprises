module Admin
  module UserImporter
    # Mass-import users from a CSV
    #

    # The CSV has columns for the “antenne” and “institution” names…
    CSV_COLUMNS = %i[full_name email phone_number role antenne institution]
    # We rework it to import with the antenne_id instead.
    IMPORTED_COLUMNS = %i[full_name email phone_number role antenne_id]

    def self.header_rewrites
      # Additionally, the CSV, since it’s used by humans, uses human attributes names for headers.
      # We have to map back to the actual attributes names.
      @header_rewrites ||= IMPORTED_COLUMNS.index_by { |a| User.human_attribute_name(a) }
    end

    def self.before_batch_import(importer)
      # The :antenne_id and :institution columns contain the antenne and institution names.
      # Institution names are unique, and Antenne names are unique among each institution.

      # Find the matching Antenne
      antenne_column = importer.header_index(:antenne_id)
      institution_column = importer.header_index('institution')
      names = importer.csv_lines.collect { |l| [l[antenne_column], l[institution_column]] }
      antennes = Antenne.by_antenne_and_institution_names(names)

      # Build a [name, name] => id hash
      names_to_id = antennes
        .pluck('antennes.name', 'institutions.name', 'antennes.id')
        .map{ |values| [[values[0], values[1]], values[2]] }
        .to_h

      # Replace the values
      importer.csv_lines.each do |l|
        names = [l[antenne_column], l[institution_column]]
        id = names_to_id[names]
        l[antenne_column] = id if id.present?
      end

      # And remove the :institution column.
      importer.batch_slice_columns(IMPORTED_COLUMNS)
    end

    def self.csv_example(users)
      columns = Admin::UserImporter::CSV_COLUMNS
      CSV.generate("", ActiveAdmin.application.csv_options) do |csv|
        csv << columns.map{ |col| User.human_attribute_name(col) }
        users.each do |user|
          csv << columns.map{ |col| user.send(col) }
        end
      end
    end
  end
end
