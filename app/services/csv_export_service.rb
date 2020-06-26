# frozen_string_literal: true

require 'csv_export/models/match'

Match.include CsvExport::Models::Match

class CsvExportService
  def self.build(relation)
    klass = relation.klass
    attributes = klass.csv_fields
    if attributes.empty?
      klass.column_names.map { |name| [name] }
    end

    csv_string = CSV.generate do |csv|
      csv << attributes.keys.map(&klass.method(:human_attribute_name))
      row = attributes.values
      relation.includes(*klass.csv_included_associations).find_each do |object|
        csv << row.map do |val|
          if val.respond_to? :call
            lambda = val
            object.instance_exec(&lambda)
          else
            object.send(val)
          end
        end
      end
    end

    model_name = klass.model_name.human.pluralize.parameterize
    file = Tempfile.new(["#{model_name}-#{Time.zone.now.iso8601}-", ".csv"])
    begin
      file.write(csv_string)
    ensure
      file.close
    end
    file
  end
end
