module Stats
  attr_reader :params

  def initialize(params = {})
    @params = OpenStruct.new(params)
  end

  module BaseStats
    FILTER_PARAMS = [
      :territory, :institution, :antenne, :subject, :integration, :mtm_campaign, :mtm_kwd,
      :start_date, :end_date, :theme, :iframe_id, :colors
    ]
    attr_reader(*FILTER_PARAMS)

    def initialize(params)
      params = OpenStruct.new(params)
      @territory = Territory.find_by(id: params.territory) if params.territory.present?
      @institution = Institution.find_by(id: params.institution) if params.institution.present?
      @antenne = Antenne.find_by(id: params.antenne) if params.antenne.present?
      @subject = Subject.find_by(id: params.subject) if params.subject.present?
      @integration = params.integration
      @iframe_id = params.iframe_id
      @mtm_campaign = params.mtm_campaign
      @mtm_kwd = params.mtm_kwd
      @theme = Theme.find_by(id: params.theme) if params.theme.present?
      @start_date = params.start_date&.to_time || (Time.zone.now.beginning_of_day - 6.months)
      @end_date = params.end_date&.to_time&.end_of_day || Time.zone.now.end_of_day
      @colors = params.colors
    end

    def date_group_attribute
      'created_at'
    end

    def colors
      @colors || %w[#62e0d3 #2D908F #f3dd68 #e78112 #F45A5B #9f3cca #F15C80 #A8FF96 #946c47 #64609b #7a7a7a #CF162B]
    end

    def series
      @series ||= build_series
    end

    def build_series
      query = grouped_by_month(filtered_main_query)
      query = grouped_by_category(query)
      results = categorized_results(query)
      results = full_results(results)
      as_series(results)
    end

    def filtered_main_query
      filtered(main_query)
    end

    def max_value
      if additive_values || build_series.blank?
        count
      else
        @max_value ||= build_series.first[:data].max
      end
    end

    def all_months
      @all_months ||= search_range_by_month.map(&:begin)
    end

    # [Sat, 01 Jul 2023..Tue, 01 Aug 2023, ...]
    def search_range_by_month
      @search_range_by_month ||= (@start_date.beginning_of_month.to_date..@end_date.end_of_month.to_date)
        .group_by(&:beginning_of_month)
        .map { |_, month| month.first..month.last }
    end

    def all_categories
      @all_categories ||= grouped_by_category(main_query)
        .group(category_order_attribute).order(category_order_attribute)
        .pluck(category_group_attribute)
    end

    def count
      @count ||= filtered(main_query).size
    end

    def secondary_count
      nil
    end

    def percentage_two_numbers(measured, others)
      sum_measured = measured.sum
      sum_others = others.sum
      total = sum_measured + sum_others
      total == 0 ? "0" : "#{(sum_measured * 100).fdiv(total).round}%"
    end

    def format
      # Format for graph tooltip
      # '{series.name} : <b>{point.percentage:.0f}%</b>'
      '{series.name} : <b>{point.y}</b> ({point.percentage:.0f}%)<br>Total: {point.stackTotal}'
    end

    def chart
      'percentage-column-chart'
    end

    def matches_colors
      @colors || %w[#eabab1 #8D533E]
    end

    def needs_colors
      @colors || %w[#2D908F #62e0d3]
    end

    def antenne_or_institution
      @antenne_or_institution = @antenne.presence || @institution.presence
    end

    ## Overrides
    #
    def subtitle
      false
    end

    def filtered(query)
      query
    end

    def additive_values
      false
    end

    def category_name(category)
      category
    end

    private

    def grouped_by_month(query)
      # Ici les mois sont en UTC
      query.group("DATE_TRUNC('month', #{query.model.name.pluralize}.created_at)")
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
        month = entry.first.first.to_datetime
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

      all_months_zero = all_months.index_with { |m| 0 }
      all_categories_results = all_categories.index_with { |c| all_months_zero.dup }

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
        category = category_name(category)
        values = month_values.values
        if additive_values
          values = values.reduce([]) { |a, v| a << (v + (a.last || 0)) }
        end

        { name: category, data: values }
      end
    end
  end
end
