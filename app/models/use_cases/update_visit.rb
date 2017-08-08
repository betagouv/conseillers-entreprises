# frozen_string_literal: true

module UseCases
  class UpdateVisit
    class << self
      def validate_happened_at happened_at
        DateTime.iso8601(happened_at)
      end
    end
  end
end
