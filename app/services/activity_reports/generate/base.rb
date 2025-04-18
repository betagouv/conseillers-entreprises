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

    def generate_files(period)
      ActiveRecord::Base.transaction do
        result = export_xls(period)
        create_file(result, period)
      end
    end

    def create_file(result, period)
      filename = build_filename(period)
      report = reports.create!(start_date: period.first, end_date: period.last)
      report.file.attach(io: result.xlsx.to_stream(true),
                         key: "activity_report_#{report_type}/#{@item.name.parameterize}/#{filename}",
                         filename: filename,
                         content_type: 'application/xlsx')
    end

    def last_periods
      needs = @item.perimeter_received_needs
      return if needs.blank?
      first_date = needs.minimum(:created_at).to_date
      periods = find_last_year_periods
      periods.reject! { |range| first_date > range.last }
      periods
    end

    def destroy_old_files(periods)
      reports.where.not(start_date: periods.flatten).destroy_all
    end

    def reports
      @item.activity_reports
    end

    def find_last_year_periods
      TimeDurationService::Quarters.new.call
    end

    def build_filename(period)
      I18n.t("activity_report_service.#{report_type}_file_name", number: TimeDurationService::Quarters.new.find_quarter_for_month(period.first.month), year: period.first.year, item: @item.name.parameterize)
    end
  end
end
