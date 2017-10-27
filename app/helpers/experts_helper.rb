# frozen_string_literal: true

module ExpertsHelper
  def expert_button_classes(classes_array = [])
    %w[ui button tiny] + classes_array
  end
end
