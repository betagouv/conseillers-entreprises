# frozen_string_literal: true

module DiagnosisV2Helper
  def classes_for_step(displayed_step, current_step = nil)
    if displayed_step == current_step
      'active'
    elsif displayed_step < current_step
      'completed'
    end
  end
end
