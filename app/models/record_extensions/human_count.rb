module RecordExtensions
  module HumanCount
    ## A readable description of an ActiveRecord::Relation
    # > user.all.human_count
    # => "12 users"
    # > user.last.experts.human_count
    # => "12 recherches"
    def human_count
      "#{size} #{model_name.human(count: size).downcase}"
    end
  end
end
