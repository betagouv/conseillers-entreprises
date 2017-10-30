# frozen_string_literal: true

module UseCases
  class UpdateVisit
    class << self
      def validate_happened_on(happened_on)
        DateTime.iso8601(happened_on, Date::GREGORIAN)
      end
    end
  end
end
