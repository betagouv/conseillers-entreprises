module Stats::Needs
  class HelpedInFiveDays
    include ::Stats::Needs::Concerns::ResponseTime

    def main_query = base_scope.status_done

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
