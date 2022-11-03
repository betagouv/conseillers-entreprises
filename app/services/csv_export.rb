module CsvExport
  # CSV Export facility.
  # Instantiate a model-specific exporter and run it.
  # See also csv_export/base_exporter.rb
  def self.export(relation, options = {})
    klass = relation.klass
    exporter_klass = "CsvExport::#{klass}Exporter".constantize
    exporter_klass.new(relation, options).export
  end

  def self.purge_later
    User.admin.with_attached_csv_exports.find_each do |user|
      user.csv_exports.each do |export|
        export.purge_later if export.created_at < 1.week.ago
      end
    end
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
