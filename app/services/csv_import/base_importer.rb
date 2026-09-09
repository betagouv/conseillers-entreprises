module CsvImport
  # CSV Importing abstract implementation, to be subclassed for specific models.
  #
  # See also csv_import.rb for the high-level API.
  class BaseImporter
    def initialize(input, options = {})
      @input = input
      @options = options
      @imported_at = Time.zone.now
    end

    def import(preview)
      csv = open_with_best_separator(@input) # Allow configuring the separator? Allow other file types?
      if csv.is_a? CSV::MalformedCSVError
        return Result.new(rows: [], header_errors: [csv], preprocess_errors: [], postprocess_errors: [], objects: [])
      end
      header_errors = check_headers(csv.headers.compact)

      rows = csv.map(&:to_h)
      objects = []
      preprocess = []
      preprocess_errors = []
      postprocess_errors = []
      ActiveRecord::Base.transaction do |transaction|
        if preview
          transaction.before_commit { raise ActiveRecord::Rollback }
        end

        # Convert CSV rows to attributes
        objects = rows.each_with_index.map do |row|
          row.delete_if { |k, v| k.nil? && v.nil? }
          # Convert row to attributes
          attributes = row_to_attributes(row)

          preprocess << preprocess(attributes)
          preprocess_errors = preprocess.grep(CsvImport::PreprocessError)
          next if preprocess_errors.present?

          # Create objects
          object, attributes = find_instance(attributes)
          next if object.nil?

          object.imported_at = @imported_at
          object.update(attributes) # here the object is created for real

          object = postprocess(object, row) # additional objects are created here as well (users, experts, experts_subjects, territorial_zones)
          postprocess_errors << object if object.is_a? CsvImport::PostprocessError
          next if postprocess_errors.present?
          object
        end

        preprocess_errors = preprocess_errors.group_by(&:message).keys
        postprocess_errors = postprocess_errors.group_by(&:message).keys
        # Validate all objects to collect errors, but rollback everything if there is one error
        all_valid = objects.map{ |object| object&.validate(:import) }
        if postprocess_errors.present? || (all_valid.include? false || preprocess_errors.present?)
          raise ActiveRecord::Rollback
        end
      end

      Result.new(rows: rows, header_errors: header_errors, preprocess_errors: preprocess_errors, postprocess_errors: postprocess_errors, objects: objects)
    end

    private

    def open_with_separator(input, col_sep)
      squish_converter = lambda { |header| header.squish }
      begin
        common_options = { headers: true, header_converters: squish_converter, col_sep: col_sep, skip_blanks: true, skip_lines: /^(?:#{col_sep}\s*)+$/ }
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
      # Split in two methods: find_best_separator and open_with_separator
      #
      separators = %w[, ;]
      attempted = separators.map { |separator| open_with_separator(input, separator) }

      opened_files = attempted.grep_v(CSV::MalformedCSVError)
      return attempted.first if opened_files.empty?

      # Find the separator that find the most headers
      # find_best_separator could use check_headers instead.
      best_index = opened_files.map { |x| x.headers.count }.each_with_index.max.second
      opened_files[best_index]
    end

    def row_to_attributes(row)
      row.transform_keys(&:squish)
        .slice(*mapping.keys)
        .transform_keys{ |k| mapping[k] } # Allow custom mapping?
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

    private

    def reformat_commune_code(code)
      # Reformat 4-digit commune codes to 5-digit codes
      if code.size == 4 && code.first != '0'
        "0#{code}"
      else
        code
      end
    end
  end
end
