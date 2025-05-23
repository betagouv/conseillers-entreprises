module Stats::Acquisitions::SolicitationsBase
  include ::Stats::BaseStats
  include Stats::Acquisitions::Base

  def main_query
    Solicitation.step_complete
  end

  def filtered(query)
    Stats::Filters::Solicitations.new(query, self).call
  end

  private

  def as_series(results)
    results.map do |key, value|
      {
        name: I18n.t("stats.series.#{key}.title"),
        data: value
      }
    end
  end
end
