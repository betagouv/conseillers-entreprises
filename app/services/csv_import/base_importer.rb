module CsvImport
  # CSV Im=porting abstract implementation, to be subclassed for specific models.
  #
  # See also csv_import.rb for the high-level API.
  class BaseImporter
    def initialize(input, options = {})
      @input = input
      @options = options
    end

    def import
      csv = open_with_best_separator(@input)
      if csv.is_a? CSV::MalformedCSVError
        return Result.new(rows: [], header_errors: [csv], preprocess_errors: [], objects: [])
      end
      header_errors = check_headers(csv.headers.compact)

      rows = csv.map(&:to_h)
      objects = []
      preprocess = []
      preprocess_errors = []
      ActiveRecord::Base.transaction do
        # Convert CSV rows to attributes
        objects = rows.each_with_index.map do |row|
          # Convert row to user attributes
          attributes = row_to_attributes(row)

          preprocess << preprocess(attributes)
          preprocess_errors = preprocess.filter { |result| result.is_a? CsvImport::PreprocessError }
          next if preprocess_errors.present?

          # Create objects
          object, attributes = find_instance(attributes)
          next if object.nil?

          object.update(attributes)

          object = postprocess(object, row)
          object
        end

        preprocess_errors = preprocess_errors.group_by(&:message).keys
        # Validate all objects to collect errors, but rollback everything if there is one error
        all_valid = objects.map{ |object| object&.validate(:import) }
        if all_valid.include? false || preprocess_errors.present?
          raise ActiveRecord::Rollback
        end
      end

      Result.new(rows: rows, header_errors: header_errors, preprocess_errors: preprocess_errors, objects: objects)
    end

    private

    def open_with_separator(input, col_sep)
      squish_converter = lambda { |header| header.squish }
      begin
        common_options = { headers: true, header_converters: squish_converter, col_sep: col_sep, skip_blanks: true, skip_lines: /^(?:,\s*)+$/ }
        if input.respond_to?(:open)
          # Unfortunately, CSV::read only takes files…
          # … and CSV::new takes strings or IO, but the IO needs to be already open.
          # @input is a file:
          CSV.read(input, **common_options)
        else
          # @input is a string:
          CSV.new(input, **common_options).read
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
      best_index = opened_files.map { |x| x.headers.count }.each_with_index.max.second
      opened_files[best_index]
    end

    def row_to_attributes(row)
      row.transform_keys(&:squish)
        .slice(*mapping.keys)
        .transform_keys{ |k| mapping[k] }
        .compact
    end

    # Methods implemented by subclasses
    #
    public

    def mapping; end

    def check_headers(headers); end

    def preprocess(attributes); end

    def find_instance(attributes); end

    def postprocess(object, attributes); end
  end
end
