require 'core_extensions/active_record/created_within'
require 'core_extensions/relation/human_count'

ActiveRecord::Base.include CoreExtensions::ActiveRecord::CreatedWithin
ActiveRecord::Relation.include CoreExtensions::Relation::HumanCount
