require 'core_extensions/active_record/created_within'
require 'core_extensions/active_record/human_attribute_value'
require 'core_extensions/delayed/job/remove_jobs'
require 'core_extensions/relation/human_count'

ActiveRecord::Base.include CoreExtensions::ActiveRecord::CreatedWithin
ActiveRecord::Base.include CoreExtensions::ActiveRecord::HumanAttributeValue
Delayed::Job.include CoreExtensions::Delayed::Job::RemoveJobs
ActiveRecord::Relation.include CoreExtensions::Relation::HumanCount
