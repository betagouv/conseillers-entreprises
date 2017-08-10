# frozen_string_literal: true

module UseCases
  class UpdateDiagnosis
    class << self
      def clean_update_params(params, current_step:)
        params[:step] = params[:step].to_i
        params.reject { |_key, value| value.blank? }.reject { |key, value| key == :step && value < current_step }
      end
    end
  end
end
