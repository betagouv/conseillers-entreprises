# Stats montrant l'evolution du nombre de demandes donnant lieu à échange avec un conseiller
module Stats::Public
  class ExchangeWithExpertColumnStats
    include ::Stats::BaseStats

    def main_query
      Need.joins(:diagnosis)
        .merge(Diagnosis.from_solicitation.completed)
        .with_exchange
    end

    # Stat principale, on ne filtre pas
    def filtered(query)
      query
    end

    def count
      main_query.count
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('stats.series.exchange_with_expert_column.series')
    end

    def chart
      'stats-chart'
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def colors
      %w[#000091]
    end
  end
end
