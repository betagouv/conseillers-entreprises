# frozen_string_literal: true

class CsvExportService
  def self.csv(relation, additional_fields = {})
    klass = relation.klass
    attributes = klass.csv_fields.merge additional_fields

    CSV.generate do |csv|
      csv << attributes.keys.map{ |attr| klass.human_attribute_name(attr, default: attr) }
      row = attributes.values
      relation.preload(*klass.csv_preloaded_associations).find_each do |object|
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
  end

  def self.filename(relation)
    model_name = relation.klass.model_name.human.pluralize.parameterize
    "#{model_name}-#{Time.zone.now.iso8601}"
  end

  def self.build_file(relation, additional_fields = {})
    file = Tempfile.new(["#{filename(relation)}-", ".csv"])
    begin
      file.write(csv(relation, additional_fields))
    ensure
      file.close
    end
    file
  end
end
