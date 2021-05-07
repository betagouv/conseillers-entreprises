module Stats::Mini::BaseStats
  def main_query
    raise 'main_query must be implemented'
  end

  def count
    main_query.count
  end
end
