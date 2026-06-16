class ActivityReports::GeneratorBase < ApplicationJob
  class EnqueueBase < ApplicationJob
    ## Enqueuing Job
    # Concrete subclasses implement #collection
    queue_as :low_priority
    def perform
      generator = self.class.module_parent
      ActiveJob.perform_all_later(collection.map { generator.new(it) })
    end

    def collection = raise NoMethodError, "The method #{__method__} needs to be implemented in #{self.class}"
  end

  ## Report generator Job
  # item may be passed as the first argument of the initializer or as the argument of #perform method.
  # i.e. `ActivityReports::<Subclass>.new(item)` or `ActivityReports::<Subclass>.perform_later(item)`.
  queue_as :low_priority

  def initialize(*arguments)
    super
    @item = arguments.first
  end

  def job_status = SidekiqJob.status_for(self.class, @item)

  def perform(item = nil)
    @item ||= item

    return if @item.perimeter_received_needs.empty?

    missing_reports_periods.each { |period| generate_report(period) }
    destroy_expired_reports
  end

  ## Methods to be implemented by subclasses
  #
  # one of `ActivityReport.categories`
  def report_type = raise NoMethodError, "The method #{__method__} needs to be implemented in #{self.class}"

  # an ordered array of `Date` ranges
  def reports_periods = raise NoMethodError, "The method #{__method__} needs to be implemented in #{self.class}"

  # `XlsxExport::Result`
  def export_xls(period) = raise NoMethodError, "The method #{__method__} needs to be implemented in #{self.class}"

  ## Reports primitives
  #
  def reports_periods_with_data
    first_date = @item.perimeter_received_needs.minimum(:created_at)&.to_date
    return [] if first_date.nil?

    reports_periods.filter { |range| range.last >= first_date }
  end

  def reports = @item.activity_reports.where(category: report_type)

  def existing_reports_periods = reports.map(&:period).sort_by(&:begin)

  def missing_reports_periods = reports_periods_with_data - existing_reports_periods

  def expired_reports = reports.where.not(start_date: reports_periods.map(&:begin))

  def generate_report(period)
    ActiveRecord::Base.transaction do
      data = export_xls(period)
      create_file(data, period)
    end
  end

  def create_file(data, period)
    filename = build_filename(period)
    key = "activity_report_#{report_type}/#{@item.id}-#{@item.name.parameterize}/#{filename}"

    # Delete any stray attachment that may have been left over from a previous (failed?) run
    blob = ActiveStorage::Blob.find_by(key: key)
    blob.attachments.each(&:purge) if blob.present?

    # Generate ActivityReport object
    report = reports.create!(start_date: period.first, end_date: period.last)

    report.file.attach(io: data.xlsx.to_stream(confirm_valid: true), key: key, filename: filename, content_type: 'application/xlsx')
  end

  def destroy_expired_reports = expired_reports.destroy_all

  def build_filename(period)
    prefix = I18n.t(report_type, scope: "reports.filename_prefix")
    item_name = @item.name.parameterize
    period_name = ActivityPeriods.period_name(period)
    "#{prefix}-#{item_name}-#{period_name}.xlsx"
  end
end
