class QuarterlyDataService
  class << self
    def matches_export
      Antenne.find_each do |antenne|
        quarters = last_quarters(antenne)
        next if quarters.nil?

        generate_matches_files(antenne, quarters)
        destroy_old_matches_files(antenne, quarters)
      end
    end

    private

    def generate_matches_files(antenne, quarters)
      quarters.each do |quarter|
        next if antenne.quarterly_datas.find_by(start_date: quarter.first).present?

        matches = Match.antenne_territory_needs(antenne, quarter.first, quarter.last)
        next if matches.blank?

        result = matches.export_xlsx
        filename = I18n.t('quarterly_data_service.matches_file_name', number: TimeDurationService.find_quarter(quarter.first.month), year: quarter.first.year)
        antenne.quarterly_datas.create(start_date: quarter.first, end_date: quarter.last)
               .file.attach(io: result.xlsx.to_stream(true),
                            key: "#{Rails.env}/quarterly_data_matches/#{antenne.name.parameterize}/#{filename}",
                            filename: filename,
                            content_type: 'application/xlsx')
      end
    end

    def destroy_old_matches_files(antenne, quarters)
      start_dates = quarters.map(&:first)
      antenne.quarterly_datas.where.not(start_date: start_dates).destroy_all
    end

    def last_quarters(antenne)
      return if antenne.received_matches.blank?
      first_match_date = antenne.received_matches.minimum(:created_at).to_date
      quarters = TimeDurationService.past_year_quarters
      quarters.reject! { |range| first_match_date > range.last }
      quarters
    end
  end
end
