module CsvImport
  class Result
    attr_reader :rows, :objects, :header_errors

    def initialize(rows:, header_errors:, objects:)
      @rows, @header_errors, @objects = rows, header_errors, objects
    end

    def success?
      @header_errors.blank? && @objects.all?(&:valid?)
    end
  end

  class UnknownHeaderError < StandardError
    attr_reader :header

    def initialize(header)
      @header = header
      super("En-tête non reconnu: « #{header} »")
    end
  end

  class BaseImporter
    def self.import(input, *args)
      self.new(input, *args).import
    end

    def initialize(input, *args)
      @input = input
    end

    def import
      begin
        if @input.respond_to?(:open)
          # Unfortunately, CSV::read only takes files…
          # … and CSV::new takes strings or IO, but the IO needs to be already open.
          # @input is a file:
          csv = CSV.read(@input, headers: true)
        else
          # @input is a string:
          csv = CSV.new(@input, headers: true).read
        end
      rescue CSV::MalformedCSVError => e
        return Result.new(rows: [], header_errors: [e], objects: [])
      end

      header_errors = check_headers(csv.headers)

      rows = csv.map(&:to_h)
      objects = []
      ActiveRecord::Base.transaction do
        # Convert CSV rows to attributes
        objects = rows.each_with_index.map do |row|
          # Convert row to user attributes
          attributes = row.slice(*mapping.keys)
            .transform_keys{ |k| mapping[k] }

          preprocess(attributes)

          # Create objects
          object = find_instance(attributes)
          object.update(attributes)

          postprocess(object, row)

          object
        end

        # Build all objects to collect errors, but rollback everything on error
        if objects.any?(&:invalid?)
          raise ActiveRecord::Rollback
        end
      end

      Result.new(rows: rows, header_errors: header_errors, objects: objects)
    end

    ## subclasses override points
    #
    def mapping; end

    def check_headers(headers); end

    def preprocess(attributes); end

    def find_instance(attributes); end

    def postprocess(object, attributes); end
  end
end
