module CsvImport
  class Result
    attr_reader :rows, :objects, :header_errors

    def initialize(rows:, header_errors:, objects:)
      @rows, @header_errors, @objects = rows, header_errors, objects
    end

    def success?
      @success ||= @header_errors.blank? && @objects.all?{ |object| object.valid?(:import) }
    end
  end

  class UnknownHeaderError < StandardError
  end

  class BaseImporter
    def self.import(input, *args)
      self.new(input, *args).import
    end

    def initialize(input, *args)
      @input = input
    end

    def import
      csv = open_with_best_separator(@input)
      if csv.is_a? CSV::MalformedCSVError
        return Result.new(rows: [], header_errors: [csv], objects: [])
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

        # Validate all objects to collect errors, but rollback everything if there is one error
        all_valid = objects.map{ |object| object.validate(:import) }
        if all_valid.include? false
          raise ActiveRecord::Rollback
        end
      end

      Result.new(rows: rows, header_errors: header_errors, objects: objects)
    end

    private

    def open_with_separator(input, col_sep)
      begin
        if input.respond_to?(:open)
          # Unfortunately, CSV::read only takes files…
          # … and CSV::new takes strings or IO, but the IO needs to be already open.
          # @input is a file:
          CSV.read(input, headers: true, col_sep: col_sep)
        else
          # @input is a string:
          CSV.new(input, headers: true, col_sep: col_sep).read
        end
      rescue CSV::MalformedCSVError => e
        return e
      end
    end

    def open_with_best_separator(input)
      separators = %w[, ;]
      attempted = separators.map { |separator| open_with_separator(input, separator) }

      opened_files = attempted.filter { |csv| !csv.is_a? CSV::MalformedCSVError }
      return attempted.first if opened_files.empty?

      # Find the separator that find the most headers
      best_index = opened_files.map(&:headers).map(&:count).each_with_index.max.second
      opened_files[best_index]
    end

    ## subclasses override points
    #
    public

    def mapping; end

    def check_headers(headers); end

    def preprocess(attributes); end

    def find_instance(attributes); end

    def postprocess(object, attributes); end
  end
end
