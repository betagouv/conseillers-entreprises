module XlsxExport
  # CSV Export facility.
  # Instantiate a model-specific exporter and run it.
  # See also csv_export/base_exporter.rb
  def self.export(relation, options = {})
    klass = relation.klass
    exporter_klass = "XlsxExport::#{klass}Exporter".constantize
    exporter_klass.new(relation, options).export
  end

  ## Helper method
  # Just call <Relation>.export_xlsx(<options>)
  module RecordExtension
    def export_xlsx(options = {})
      ## Note:
      # This is added as a class method on ApplicationRecord, but sent on ActiveRecord::Relation instances.
      # This is ok because Relation delegates to the underlying model class.
      # current_scope lets us find the actual relation being used.
      XlsxExport.export(current_scope, options)
    end
  end

  class Result
    attr_reader :xlsx, :filename

    def initialize(xlsx:)
      @xlsx = xlsx
    end
  end
end
