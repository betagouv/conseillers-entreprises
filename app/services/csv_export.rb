module CsvExport
  def self.export(relation, options = {})
    klass = relation.klass
    exporter_klass = "CsvExport::#{klass}Exporter".constantize
    exporter_klass.new(relation, options).export
  end

  ## Helper method
  # Just call <Relation>.export_csv(<options>)
  module RecordExtension
    def export_csv(options = {})
      ## Note:
      # This is added as a class method on ApplicationRecord, but sent on ActiveRecord::Relation instances.
      # This is ok because Relation delegates to the underlying model class.
      # current_scope lets us find the actual relation being used.
      CsvExport.export(current_scope, options)
    end
  end

  class Result
    attr_reader :csv, :filename

    def initialize(csv:, filename:)
      @csv, @filename = csv, filename
    end

    def build_file
      file = Tempfile.new(["#{filename}-", ".csv"])
      begin
        file.write(csv)
      ensure
        file.close
      end
      file
    end
  end
end
