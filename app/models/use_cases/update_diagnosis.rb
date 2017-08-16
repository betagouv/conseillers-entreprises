# frozen_string_literal: true

module UseCases
  class UpdateDiagnosis
    class << self
      def clean_update_params(params, current_step:)
        params[:step] = params[:step].to_i if params.key?(:step)
        params.delete_if { |_key, value| value.blank? }
        params.delete_if { |key, value| key == :step && value < current_step }
        params
      end
    end
  end
end
