# frozen_string_literal: true

module UseCases
  class UpdateDiagnosis
    class << self
      def clean_update_params(params, current_step:)
        if params.key?(:step)
          params[:step] = params[:step].to_i
        end
        params.delete_if { |_key, value| value.blank? }
        params.delete_if { |key, value| key.to_sym == :step && value < current_step }
        params
      end
    end
  end
end
