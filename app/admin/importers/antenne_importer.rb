module Admin
  module Importers
    module AntenneImporter
      extend ActiveSupport::Concern
      # Mass-import Antennes from a CSV
      #

      # The CSV has columns for the “institution” name…
      CSV_COLUMNS = %i[name institution]
      # We rework it to import with the institution_id instead.
      IMPORTED_COLUMNS = %i[name institution_id]

      included do
        def self.csv_example(user)
          objects = user.institution.antennes.order(created_at: :desc)

          columns = CSV_COLUMNS
          CSV.generate("", ActiveAdmin.application.csv_options) do |csv|
            csv << columns.map{ |col| self.human_attribute_name(col) }
            objects.each do |object|
              csv << columns.map{ |col| object.send(col) }
            end
          end
        end

        def self.csv_header_rewrites
          # The CSV, since it’s used by humans, uses human attributes names for headers.
          # We have to map back to the actual attributes names.
          @header_rewrites ||= IMPORTED_COLUMNS.index_by { |a| self.human_attribute_name(a) }
        end

        def self.csv_before_batch_import(importer)
          # Replace institution names with their ids
          # See https://github.com/activeadmin-plugins/active_admin_import/wiki/change-columns-on-the-fly-by-association
          institutions_names = importer.values_at(:institution_id)
          institutions_names_to_ids = Institution.where(name: institutions_names)
            .pluck(:name, :id)
            .to_h
          importer.batch_replace(:institution_id, institutions_names_to_ids)
        end
      end
    end
  end
end
