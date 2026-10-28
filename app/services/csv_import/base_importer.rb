module CsvImport
  # CSV Importing abstract implementation, to be subclassed for specific models.
  #
  # See also csv_import.rb for the high-level API.
  class BaseImporter
    def self.import(...) = new(...).import

    def initialize(input, institution:, commit: true, col_sep: nil, &before_end_block)
      @imported_at = Time.zone.now
      @input = input.respond_to?(:open) ? input.open : input
      @institution = institution
      @commit = commit
      @col_sep = col_sep
      @before_end_block = before_end_block
    end

    def col_sep
      @col_sep ||= find_best_separator(@input)
    end

    def import
      begin
        csv = open_with_separator(@input, col_sep) # Allow configuring the separator? Allow other file types?
      rescue CSV::MalformedCSVError => e
        return Result.new(rows: [], header_errors: [e], preprocess_errors: [], postprocess_errors: [], objects: [])
      end

      header_errors = check_headers(csv.headers.compact)

      rows = csv.map(&:to_h)
      objects = []
      preprocess = []
      preprocess_errors = []
      postprocess_errors = []
      ActiveRecord::Base.transaction do |transaction|
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
          object.update(attributes)

          object = postprocess(object, row)
          postprocess_errors << object if object.is_a? CsvImport::PostprocessError
          next if postprocess_errors.present?
          object
        end

        preprocess_errors = preprocess_errors.group_by(&:message).keys
        postprocess_errors = postprocess_errors.group_by(&:message).keys
        # Validate all objects to collect errors, but rollback everything if there is one error
        all_valid = objects.map{ |object| object&.validate(:import) }
        if postprocess_errors.present? || all_valid.include?(false) || preprocess_errors.present?
          raise ActiveRecord::Rollback
        end

        @before_end_block&.call
        raise ActiveRecord::Rollback unless @commit
      end

      Result.new(rows: rows, header_errors: header_errors, preprocess_errors: preprocess_errors, postprocess_errors: postprocess_errors, objects: objects)
    end

    # @return [CSV::Table, Array, ] opened file
    # @raise [CSV::MalformedCSVError]
    def open_with_separator(input, col_sep)
      squish_converter = lambda { |header| header.squish }

      common_options = { headers: true, header_converters: squish_converter, col_sep: col_sep, skip_blanks: true, skip_lines: /^(?:#{col_sep}\s*)+$/ }
      CSV.new(input, **common_options).read
    end

    # @return [String] the found separator
    # @raise [CSV::MalformedCSVError]
    def find_best_separator(input, col_seps: %w[, ;])
      files_or_exceptions = col_seps.map do |separator|
        begin
          file_or_exception = open_with_separator(input, separator)
        rescue CSV::MalformedCSVError => e
          file_or_exception = e
        ensure
          input.rewind if input.is_a? IO
        end
        file_or_exception
      end

      opened_files = files_or_exceptions.grep_v(CSV::MalformedCSVError)
      raise files_or_exceptions.first if opened_files.empty?

      # Find the separator that find the most headers
      best_index = opened_files.map { |x| x.headers.count }.each_with_index.max.second
      col_seps[best_index]
    end

    def row_to_attributes(row)
      row.transform_keys(&:squish)
        .slice(*mapping.keys)
        .transform_keys{ |k| mapping[k] }
        .compact
    end

    # Methods implemented by subclasses
    #
    def mapping; end

    def check_headers(headers); end

    def preprocess(attributes); end

    def find_instance(attributes); end

    def postprocess(object, attributes); end

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
