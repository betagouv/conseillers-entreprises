module Stats
  class PublicTakingCareStats
    include BaseStats

    def main_query
      Solicitation.status_processed
      Match.where.not(taken_care_of_at: nil).group_by { |m| m.diagnosis.solicitation }
      Match.group_by { |m| m.taken_care_of_at.between?(m.created_at, m.created_at + 7.days ) }
    end

    def date_group_attribute
      'solicitations.created_at'
    end

    def filtered(query)
      if territory.present?
        query = query.merge(territory.companies)
      end
      if @start_date.present?
        query = query.where("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)
      groups = group_by_date(query)

      taken_care_before = taken_care_before(groups)
      taken_care_after = taken_care_after(groups)

      as_series(taken_care_before, taken_care_after)
    end

    def category_order_attribute
      Arel.sql('true')
    end

    private

    def as_series(taken_care_before, taken_care_after)
      [
        {
          name: I18n.t('stats.taken_care_before'),
            data: taken_care_before
        },
        {
          name: I18n.t('stats.taken_care_after'),
            data: taken_care_after
        }
      ]
    end
  end
end
