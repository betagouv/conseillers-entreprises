module Stats::Needs
  class TakenCareInFiveDays
    include ::Stats::Needs::Concerns::TakingCareTime

    def number_of_days
      @number_of_days ||= 5
    end

    def taken_care_after_label
      I18n.t('stats.taken_care_in_five_days.taken_care_after')
    end

    def taken_care_before_label
      I18n.t('stats.taken_care_in_five_days.taken_care_before')
    end
  end
end
