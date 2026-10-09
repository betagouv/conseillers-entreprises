module CsvImport
  # See csv_import/base_importer.rb and subclasses.
  #
  # Errors reporting relies (a lot, maybe too much) on ActiveRecord validation.
  # See nested_errors_helper.rb for a UI-side helper.

  class Result
    attr_reader :rows, :objects, :header_errors, :preprocess_errors, :postprocess_errors

    def initialize(rows:, header_errors:, objects:, preprocess_errors:, postprocess_errors:)
      @rows, @header_errors, @objects, @preprocess_errors, @postprocess_errors = rows, header_errors, objects, preprocess_errors, postprocess_errors
    end

    def success?
      @success ||= @header_errors.blank? && @preprocess_errors.blank? && @postprocess_errors.blank? && @objects.none?{ |object| object&.errors.present? }
    end
  end

  class UnknownHeaderError < StandardError
  end

  class PreprocessError < StandardError
    class AntenneNotFound < PreprocessError
      def message
        I18n.t('annuaire.base.import_errors.antenne_not_found', name: super)
      end
    end
  end

  class PostprocessError < StandardError
    def message
      I18n.t('annuaire.base.import_errors.import_failed_with_error', error: super)
    end
  end
end
