# Note: human_count could be added as a class method of ApplicationRecord and could still be called on ActiveRecord::Relation
# However, this would break the result cache (especially the count cache) in Relation.
Rails.application.reloader.to_prepare do
  # Adding the extension inside a to_prepare block is required for Zeitwerk autoloading to work properly.
  # See https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots
  ActiveRecord::Relation.include RecordExtensions::HumanCount
end
