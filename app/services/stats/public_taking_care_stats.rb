module Stats
  class PublicTakingCareStats
    include BaseStats

    def main_query
      Solicitation
        .status_processed
        .joins(diagnoses: [needs: :matches])
        .distinct
    end

    def date_group_attribute
      'solicitations.created_at'
    end

    def group_by_date(query)
      query.group_by do |solicitation|
        solicitation.matches.pluck(:taken_care_of_at).compact.min&.between?(solicitation.created_at, solicitation.created_at + 5.days)
      end
    end

    def taken_care_before(query)
      return if query[true].nil?
      query[true].group_by_month(&:created_at).map { |_, v| v.size }
    end

    def taken_care_after(query)
      return if query[false].nil?
      query[false].group_by_month(&:created_at).map { |_, v| v.size }
    end

    def filtered(query)
      if territory.present?
        query.where!(diagnoses: territory.diagnoses)
      end
      if @start_date.present?
        query.where!("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
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
