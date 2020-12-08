module Stats
  class SolicitationsStats
    include BaseStats

    def main_query
      Solicitation.all
    end

    def date_group_attribute
      'created_at'
    end

    def filtered(query)
      query
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('activerecord.models.solicitation.other')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end
  end
end
