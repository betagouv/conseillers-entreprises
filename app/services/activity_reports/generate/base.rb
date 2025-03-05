module ActivityReports::Generate
  class Base
    def initialize(item)
      @item = item
    end

    def call
      periods = last_periods
      return if periods.nil?
      periods.each do |period|
        generate_files(period)
      end
      destroy_old_files(periods)
    end

    private

    def destroy_old_files(periods)
      reports.where.not(start_date: periods.flatten).destroy_all
    end

    def reports
      @item.activity_reports
    end

    def last_quarters
      needs = @item.perimeter_received_needs
      return if needs.blank?
      first_date = needs.minimum(:created_at).to_date
      quarters = TimeDurationService.past_year_quarters
      quarters.reject! { |range| first_date > range.last }
      quarters
    end
  end
end
