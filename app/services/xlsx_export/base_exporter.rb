module XlsxExport
  # XLS Exporting abstract implementation, to be subclassed for specific models.
  #
  # See also xls_export.rb for the high-level API.
  class BaseExporter
    def initialize(relation, options = {})
      @relation = relation
      @options = options
    end

    def export
      Result.new(xlsx: xlsx)
    end

    def xlsx
      klass = @relation.klass
      attributes = fields # implemented by subclasses

      p = Axlsx::Package.new
      wb = p.workbook

      create_styles wb.styles

      wb.add_worksheet(name: @relation.klass.model_name.human.pluralize) do |sheet|
        build_headers_rows sheet, attributes, klass
        build_rows sheet, attributes
        apply_style sheet, attributes
      end

      p.use_shared_strings = true
      p
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
