module Stats::Concerns
  # category_buckets is an ordered list of [key, condition_sql | :else].
  # Must be included after Stats::BaseStats so `super` resolves to the base pipeline.
  module PartitionedCategory
    def category_group_attribute
      whens = category_buckets.reject { |_, condition| condition == :else }
        .map { |key, condition| "WHEN (#{condition}) THEN '#{key}'" }
      else_bucket = category_buckets.find { |_, condition| condition == :else }
      else_clause = else_bucket ? "ELSE '#{else_bucket.first}'" : ''
      Arel.sql("CASE #{whens.join(' ')} #{else_clause} END")
    end

    # Fixed order so empty categories still appear, without an extra query.
    def all_categories
      category_buckets.map { |key, _| key.to_s }
    end

    def categorized_results(query)
      super.tap { |results| results.delete(nil) }
    end
  end
end
