module QuestionnaireHelper
  def display_questionnaire_modal?
    ENV['DISPLAY_QUESTIONNAIRE2026_1'] == 'true' &&
      current_user.present? &&
      !current_user.questionnaire_2026_done &&
      (!current_user.questionnaire_2026_seen || current_user.questionnaire_2026_seen < 1.week.ago)
  end

  def questionnaire_url
    ENV['QUESTIONNAIRE2026_1_URL']
  end
end
