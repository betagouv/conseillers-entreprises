module Stats::Needs
  class TakenCareInThreeDays
    include ::Stats::Needs::Concerns::TakingCareTime

    def number_of_days
      @number_of_days ||= 3
    end

    def taken_care_after_label
      I18n.t('stats.taken_care_in_three_days.taken_care_after')
    end

    def taken_care_before_label
      I18n.t('stats.taken_care_in_three_days.taken_care_before')
    end
  end
end
