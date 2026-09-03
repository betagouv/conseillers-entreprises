module Stats::Concerns
  # Collapses a per-month, per-series Ruby loop into a single grouped SQL query
  # by expressing the "category" (the coloured series of a stacked bar) as a SQL
  # CASE that partitions each row into exactly one mutually-exclusive bucket.
  #
  # Including graphs declare `category_buckets`: an ordered list of
  # `[key, condition_sql | :else]`. The declared order is the display/series
  # order. At most one `:else` bucket catches the remaining rows; a row matching
  # no bucket yields a NULL category and is dropped — this faithfully reproduces
  # `where.not(<null-valued expression>)` semantics (e.g. NULL timestamps).
  #
  # Must be included AFTER Stats::BaseStats so `super` resolves to the base
  # pipeline.
  module PartitionedCategory
    def category_group_attribute
      whens = category_buckets.reject { |_, condition| condition == :else }
        .map { |key, condition| "WHEN (#{condition}) THEN '#{key}'" }
      else_bucket = category_buckets.find { |_, condition| condition == :else }
      else_clause = else_bucket ? "ELSE '#{else_bucket.first}'" : ''
      Arel.sql("CASE #{whens.join(' ')} #{else_clause} END")
    end

    # Fixed, ordered category list: empty buckets survive and series order is
    # deterministic, without an extra DB query.
    def all_categories
      category_buckets.map { |key, _| key.to_s }
    end

    def categorized_results(query)
      super.tap { |results| results.delete(nil) }
    end
  end
end
