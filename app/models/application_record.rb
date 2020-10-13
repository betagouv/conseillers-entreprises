class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend CsvExport::RecordExtension # added as ApplicationRecord class methods, but actually used for instances of ActiveRecord::Relation
  extend CsvImport::RecordExtension
end
