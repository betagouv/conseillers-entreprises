module Stats::Needs
  class Requalification
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      # This stat is available since 2020-09-01
      needs_base_scope
        .where(created_at: Time.zone.local(2020, 9, 1)..)
        .joins(diagnosis: { solicitation: :landing_subject })
    end

    # series[0] = not_requalified (compared), series[1] = requalified (target).
    # Both conditions are explicit (no :else) so needs without a comparable
    # landing_subject fall out of both buckets, as in the original scopes.
    def category_buckets
      [
        [:not_requalified, 'needs.subject_id = landing_subjects.subject_id'],
        [:requalified, 'needs.subject_id != landing_subjects.subject_id']
      ]
    end

    def category_name(key)
      I18n.t("stats.series.needs_requalification.#{key}")
    end

    def subtitle
      nil
    end
  end
end
