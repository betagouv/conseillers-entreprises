module RecordExtensions
  module HumanCount
    ## A readable description of an ActiveRecord::Relation
    # > user.all.human_count
    # => "12 users"
    # > user.last.experts.human_count
    # => "12 recherches"
    def human_count
      attribute_count = if self.respond_to?(:proxy_association)
        relation_name = self.proxy_association.reflection.name
        count_attribute_name = "#{relation_name}_count"
        self.proxy_association.owner.attributes[count_attribute_name]
      end
      count = attribute_count || self.size
      "#{count} #{self.model_name.human(count: count).downcase}"
    end
  end
end
