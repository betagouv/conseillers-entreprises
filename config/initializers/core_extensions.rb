# Note: human_count could be added as a class method of ApplicationRecord and could still be called on ActiveRecord::Relation
# However, this would break the result cache (especially the count cache) in Relation.
# Adding it in an extension isn’t ideal, as this breaks autoreload for human_count.rb, and Zeitwerk may complain.
# However this is better than accidental n+1 queries.
ActiveRecord::Relation.include RecordExtensions::HumanCount
