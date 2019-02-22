module Stats
  class MatchesStats
    include BaseStats

    def main_query
      Match
        .joins(:advisor)
    end

    def date_group_attribute
      'matches.created_at'
    end

    def filtered(query)
      if params.territory.present?
        query.merge! Territory.find(params.territory).matches
      end
      if params.institution.present?
        query.merge! Institution.find(params.institution).sent_matches
      end

      query
    end

    def category_group_attribute
      'matches.status'
    end

    def category_name(category)
      I18n.t("activerecord.attributes.match.statuses.#{category}")
    end

    def category_order_attribute
      'matches.status'
    end
  end
end
