module CsvExport
  # CSV Exporting abstract implementation, to be subclassed for specific models.
  #
  # See also csv_export.rb for the high-level API.
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
      attributes = fields # implemented by subclasses

      CSV.generate do |csv|
        csv << attributes.keys.map{ |attr| klass.human_attribute_name(attr, default: attr) }
        row = attributes.values
        sort_relation(@relation).find_each do |object|
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

    # Methods implemented by subclasses

    # The mapping from ActiveRecord attributes to csv column names.
    def fields
      raise NotImplementedError
    end

    # The preloaded associations for the query
    def preloaded_associations
      raise NotImplementedError
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations)
    end
  end
end
