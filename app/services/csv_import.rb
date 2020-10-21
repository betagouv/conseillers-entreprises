module CsvImport
  def self.import(klass, input, options = {})
    # Look for an Importer class with a matching name
    importer_klass = "CsvImport::#{klass}Importer".constantize
    importer_klass.new(input, options).import
  end

  ## Helper method
  # Just call <ModelClass>.import_csv(<file_or_string>, <option>)
  module RecordExtension
    def import_csv(input, options = {})
      CsvImport.import(self, input, options)
    end
  end

  class Result
    attr_reader :rows, :objects, :header_errors

    def initialize(rows:, header_errors:, objects:)
      @rows, @header_errors, @objects = rows, header_errors, objects
    end

    def success?
      @success ||= @header_errors.blank? && @objects.none?{ |object| object.errors.present? }
    end
  end

  class UnknownHeaderError < StandardError
  end
end
