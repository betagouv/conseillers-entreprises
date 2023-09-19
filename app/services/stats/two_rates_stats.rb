module Stats::TwoRatesStats
  # Ex: [11, 7, 4, 6, 3, 7, 32]
  def main_array
    @main_array ||= series[1][:data]
  end

  def compared_array
    @compared_array ||= series[0][:data]
  end

  def count
    series
    percentage_two_numbers(main_array, compared_array)
  end

  def secondary_count
    main_array.sum
  end
end
