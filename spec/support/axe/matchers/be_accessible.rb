module SpecHelpers
  module Axe
    module BeAccessibleMatcherDescription
      # RSpec::Matchers wants matchers to implement #description, otherwise it complains loudly.
      # From `generated_descriptions.rb`:
      #
      # > RSpec expects the matcher to have a #description method. You should either
      # > add a String to the example this matcher is being used in, or give it a
      # > description method. Then you won't have to suffer this lengthy warning again.
      #
      # As of version 2.6.1 of axe-matchers, Axe::Matchers::BeAccessible lacks a #description method.
      # Well.
      def description
        'be accessible'
      end
    end
    ::Axe::Matchers::BeAccessible.include BeAccessibleMatcherDescription
  end
end
