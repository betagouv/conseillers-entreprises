class ActivityReports::AntenneMatches < ActivityReports::GeneratorBase
  class Enqueue < EnqueueBase
    def collection = Antenne.all
  end

  def generate_report(period)
    needs = @item.perimeter_received_needs.created_between(period.begin, period.end)
    return if needs.blank?

    matches = Match.joins(:need).where(need: needs)
    return if matches.blank?

    # la tâche peut être longue, on la met dans une transaction pour garantir un état stable (pas de Matchreport sans fichier, par exemple)
    ActiveRecord::Base.transaction do
      result = matches.export_xlsx
      create_file(result, period)
    end
  end

  def report_type = :matches

  def reports_periods = TimeDurationService::Months.new.call

  def build_filename(period)
    I18n.t("activity_report_service.#{report_type}_file_name", month: period.first.month, year: period.first.year, item: @item.name.parameterize)
  end
end
