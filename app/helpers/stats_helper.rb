module StatsHelper
  def stats_count(count)
    number_with_delimiter(count, locale: :fr, delimiter: ' ')
  end

  def stats_title(data, name)
    if data.secondary_count.present?
      stats_title_with_secondary_count(data, name)
    else
      stats_title_simple(data, name)
    end
  end

  private

  def stats_title_simple(data, name)
    t('title', scope: stats_title_scope(name), count: data.count)
  end

  def stats_title_with_secondary_count(data, name)
    count = data.secondary_count
    t('title', scope: stats_title_scope(name), count: count, secondary_count: stats_count(count))
  end

  def stats_title_scope(name)
    ['stats', 'series', name]
  end
end
