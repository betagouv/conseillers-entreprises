module Stats::Solicitations
  class FiveDaysDelay
    include ::Stats::Solicitations::TakingCareTime

    def delay
      @delay ||= 5.days
    end

    def taken_care_after_label
      I18n.t('stats.five_days_delay.taken_care_after')
    end

    def taken_care_before_label
      I18n.t('stats.five_days_delay.taken_care_before')
    end
  end
end
