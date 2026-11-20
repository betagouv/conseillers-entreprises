module MaintenanceBannerHelper
  # Announce a maintenance with FEATURE_MAINTENANCE_BANNER_START_AT and, optionally,
  # FEATURE_MAINTENANCE_BANNER_END_AT (YYYY-MM-DDTHH:MM).
  # The banner hides itself once the maintenance has started.
  def maintenance_banner_title
    start = maintenance_time('FEATURE_MAINTENANCE_BANNER_START_AT')
    return unless start&.future?

    finish = maintenance_time('FEATURE_MAINTENANCE_BANNER_END_AT')
    if finish.nil? || finish <= start
      t('shared.maintenance_banner.title.from', date: maintenance_day(start), time: maintenance_hour(start))
    elsif finish.to_date == start.to_date
      t('shared.maintenance_banner.title.same_day', date: maintenance_day(start), start_time: maintenance_hour(start), end_time: maintenance_hour(finish))
    else
      t('shared.maintenance_banner.title.several_days',
        start_date: maintenance_day(start), start_time: maintenance_hour(start),
        end_date: maintenance_day(finish), end_time: maintenance_hour(finish))
    end
  end

  private

  def maintenance_time(env_key)
    value = ENV[env_key]
    return if value.blank?

    Time.zone.iso8601(value)
  rescue ArgumentError
    nil
  end

  def maintenance_day(time) = l(time.to_date, format: :with_day_name)

  def maintenance_hour(time) = l(time, format: :hour)
end
