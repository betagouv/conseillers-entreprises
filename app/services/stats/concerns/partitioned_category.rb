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
      super.tap { |results| warn_on_unexpected_nil_category(results.delete(nil)) }
    end

    private

    def warn_on_unexpected_nil_category(dropped_month_counts)
      return if dropped_month_counts.blank?
      return unless category_buckets.any? { |_, condition| condition == :else }

      Rails.logger.warn(
        "[#{self.class}] #{dropped_month_counts.values.sum} row(s) matched no category " \
        'despite an :else bucket being declared - category_buckets may be out of sync with the data.'
      )
    end
  end
end
