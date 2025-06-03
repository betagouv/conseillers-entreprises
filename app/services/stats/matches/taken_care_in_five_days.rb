module Stats::Matches
  # Taux de mises en relation en cours de prises en charge sur l’ensemble des mises en relation transmises
  class TakenCareInFiveDays
    include ::Stats::Matches::TakingCareTime

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
