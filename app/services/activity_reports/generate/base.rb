module ActivityReports::Generate
  class Base
    def initialize(item)
      @item = item
    end

    def call
      periods = last_periods
      return if periods.nil?
      periods.each do |period|
        generate_files(period) if reports.find_by(start_date: period.first).blank?
      end
      destroy_old_files(periods)
    end

    private

    def generate_files(quarter)
      ActiveRecord::Base.transaction do
        result = export_xls(quarter)
        create_file(result, quarter)
      end
    end

    def create_file(result, quarter)
      filename = I18n.t("activity_report_service.#{report_type}_file_name", number: TimeDurationService.find_quarter_for_month(quarter.first.month), year: quarter.first.year, item: @item.name.parameterize)
      report = reports.create!(start_date: quarter.first, end_date: quarter.last)
      report.file.attach(io: result.xlsx.to_stream(true),
                         key: "activity_report_#{report_type}/#{@item.name.parameterize}/#{filename}",
                         filename: filename,
                         content_type: 'application/xlsx')
    end

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
