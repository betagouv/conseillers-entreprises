# frozen_string_literal: true

module UseCases
  class UpdateDiagnosis
    class << self
      def clean_update_params(params, current_step:)
        params.reject { |_, v| v.blank? }
              .reject { |k, v| k == :step && safe_to_int_conversion(v).try(:<, current_step) }
              .reject { |k, v| k == :step && safe_to_int_conversion(v).try(:>, 5) }
      end

      private

      def safe_to_int_conversion(int)
        Integer(int)
      rescue ArgumentError
        -1
      end
    end
  end
end
