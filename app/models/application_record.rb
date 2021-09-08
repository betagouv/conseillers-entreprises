class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include RecordExtensions::CreatedWithin
  include RecordExtensions::HumanAttributeValue
  extend CsvExport::RecordExtension # added as ApplicationRecord class methods, but actually used for instances of ActiveRecord::Relation
  extend XlsxExport::RecordExtension # added as ApplicationRecord class methods, but actually used for instances of ActiveRecord::Relation
  extend CsvImport::RecordExtension
end
