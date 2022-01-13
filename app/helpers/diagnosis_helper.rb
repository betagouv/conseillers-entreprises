# frozen_string_literal: true

module DiagnosisHelper
  def html_classes_for_step(displayed_step, current_page_step, diagnosis_step)
    is_completed = displayed_step < diagnosis_step
    is_active = displayed_step == current_page_step

    if is_completed && is_active
      'active completed'
    elsif is_active
      'active'
    elsif is_completed
      'completed'
    end
  end
end
