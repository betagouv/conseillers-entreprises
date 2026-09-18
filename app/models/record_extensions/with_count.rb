module RecordExtensions
  ## Fast load the count of related objects in a single SQL query,
  # rather than fully preloading the related objects only to count them,
  # or worse, enumerating with N+1 requests.
  #
  # > Institution.limit(3).with_count(:antennes, :advisors, :experts)
  #     .to_a.pluck(:slug, :antennes_count, :advisors_count, :experts_count)
  # => [["cci", 110, 1776, 749], ["dgfip", 102, 263, 101], ["dreets", 115, 880, 303]]
  module WithCount
    def with_count(*relations)
      # Build SQL COUNT expressions for each relation
      sql_counts = relations.map do |relation|
        table_name = reflect_on_association(relation).klass.table_name
        "COUNT(DISTINCT #{table_name}.id) AS #{relation}_count"
      end

      # Declare a common table expression with the id and the counts
      cte = self.klass
        .left_outer_joins(*relations)
        .group("#{self.table_name}.id")
        .select("#{self.table_name}.id", *sql_counts)

      # Augment the current query with the CTE
      self.with(with_count_cte: cte)
        .joins("INNER JOIN with_count_cte ON with_count_cte.id = #{self.table_name}.id")
        .select("#{self.table_name}.*", "with_count_cte.*")
    end
  end
end
