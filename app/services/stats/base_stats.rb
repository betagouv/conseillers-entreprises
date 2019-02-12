module Stats
  module BaseStats
    attr_reader :params
    def initialize(params)
      @params = params
    end

    def series
      @series ||= build_series
    end

    def build_series
      query = main_query
      query = filtered(query) if respond_to? :filtered
      query = grouped_by_month(query)
      query = grouped_by_category(query)
      results = categorized_results(query)
      results = full_results(results)
      as_series(results)
    end

    def max_value
      @max_value ||= grouped_by_month(main_query).count.values.max
    end

    def all_months
      @all_months ||= grouped_by_month(main_query).count.keys
    end

    def all_categories
      @all_categories ||= grouped_by_category(main_query)
        .group(category_order_attribute).order(category_order_attribute)
        .pluck(category_group_attribute)
    end

    def count
      filtered(main_query).count
    end

    private

    def grouped_by_month(query)
      query.group_by_month(date_group_attribute)
    end

    def grouped_by_category(query)
      query.group(category_group_attribute)
    end

    def categorized_results(query)
      # We have:
      # {
      #  [month1, category1] => count1,
      #  [month2, category1] => count2,
      #  ...
      # }
      # We want:
      # [
      #  category1 => [
      #   month1 => count1,
      #   month2 => count2
      #  ],
      #  ...
      # ]

      query.count.each_with_object({}) do |entry, hash|
        month = entry.first.first
        category = entry.first.second
        count = entry.second
        hash[category] ||= {}
        hash[category][month] = count
      end
    end

    def full_results(results)
      # We have:
      # [
      #  category1 => [
      #   month1 => count1
      #   month2 => count2
      #   ...
      #   missing empty months
      #   ..
      #  ],
      #  ...
      #  missing empty categories
      #  ...
      # ]

      all_months_zero = all_months.map { |m| [m, 0] }.to_h
      all_categories_results = all_categories.map { |c| [c, all_months_zero.dup] }.to_h

      results.each do |category, month_values|
        all_categories_results[category].merge! month_values
      end

      all_categories_results
    end

    def as_series(results)
      # We have:
      # [
      #  category1 => [
      #   month1 => count1, # only contains nonzero months
      #   month2 => count2
      #  ],
      #  ...
      # ]
      # We want
      # [
      #  {
      #   name: 'category 1',
      #   data: [0, 0, count1, count2, 0...]
      #  },
      #  ...
      # ]

      results.map do |category, month_values|
        category = category_name(category) if respond_to? :category_name
        {
          name: category,
          data: month_values.values
        }
      end
    end
  end
end
