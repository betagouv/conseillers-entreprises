module RecordExtensions
  module HumanCount
    ## A readable description of an ActiveRecord::Relation
    # > user.all.human_count
    # => "12 users"
    # > user.last.searches.human_count
    # => "12 recherches"
    def human_count
      "#{current_scope.size} #{model_name.human(count: current_scope.size).downcase}"
    end
  end
end
