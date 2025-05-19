module Stats::Solicitations
  class ThreeDaysDelay
    include ::Stats::Solicitations::TakingCareTime

    def delay
      @delay ||= 3.days
    end

    def taken_care_after_label
      I18n.t('stats.three_days_delay.taken_care_after')
    end

    def taken_care_before_label
      I18n.t('stats.three_days_delay.taken_care_before')
    end
  end
end
