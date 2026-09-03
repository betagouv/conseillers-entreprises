module Stats::Concerns
  # Collapses a per-month, per-series Ruby loop into a single grouped SQL query
  # using independent `COUNT(*) FILTER (WHERE ...)` aggregates — one per series.
  #
  # Unlike PartitionedCategory, buckets are NOT mutually exclusive: a row may be
  # counted in several buckets. This preserves the acquisitions semantics where
  # a solicitation can match both a campaign and an integration, and
  # `from_others` is derived by subtraction (total − Σ others), possibly negative.
  #
  # Including graphs declare `aggregate_filters`: an ordered
  # `{ series_key => condition_sql }` hash (insertion order = series order) and
  # may override `with_others?` to prepend the computed `from_others` series.
  module FilteredAggregates
    def build_filtered_series
      rows = indexed_aggregate_rows
      series = aggregate_filters.keys.map do |key|
        { name: aggregate_series_name(key), data: all_months.map { |month| rows.dig(month, key).to_i } }
      end
      return series unless with_others?

      others = { name: aggregate_series_name(:from_others), data: all_months.map { |month| others_count(rows, month) } }
      series.unshift(others)
    end

    def with_others?
      false
    end

    private

    def indexed_aggregate_rows
      scope = filtered(main_query)
      month_sql = month_group_sql(scope)

      selects = [Arel.sql("#{month_sql} AS month")]
      aggregate_filters.each { |key, condition| selects << Arel.sql("COUNT(*) FILTER (WHERE #{condition}) AS #{key}") }
      selects << Arel.sql('COUNT(*) AS total_count') if with_others?

      keys = aggregate_filters.keys
      keys += [:total_count] if with_others?

      scope.group(Arel.sql(month_sql)).pluck(*selects).each_with_object({}) do |row, hash|
        month = row.first.to_date.beginning_of_month
        hash[month] = keys.zip(row.drop(1)).to_h
      end
    end

    def others_count(rows, month)
      data = rows[month]
      return 0 if data.blank?

      data[:total_count].to_i - aggregate_filters.keys.sum { |key| data[key].to_i }
    end

    def aggregate_series_name(key)
      I18n.t("stats.series.#{key}.title")
    end
  end
end
