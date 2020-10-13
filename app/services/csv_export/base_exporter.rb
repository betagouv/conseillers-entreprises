module CsvExport
  class BaseExporter
    def initialize(relation, options = {})
      @relation = relation
      @options = options
    end

    def export
      Result.new(csv: csv, filename: filename)
    end

    def csv
      klass = @relation.klass
      attributes = fields

      CSV.generate do |csv|
        csv << attributes.keys.map{ |attr| klass.human_attribute_name(attr, default: attr) }
        row = attributes.values
        @relation.preload(*preloaded_associations).find_each do |object|
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

    def filename
      model_name = @relation.klass.model_name.human.pluralize.parameterize
      "#{model_name}-#{Time.zone.now.iso8601}"
    end
  end
end
