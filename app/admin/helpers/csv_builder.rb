module Admin
  module Helpers
    ## Additional helpers for the :csv blocks
    #
    module CSVBuilderHelpers
      def column_count(attribute)
        column(attribute) { |object| object.send(attribute).size }
      end

      def column_list(association)
        column(association) { |object| object.send(association).map(&:to_s).join('/') }
      end
    end

    ActiveAdmin::CSVBuilder.include CSVBuilderHelpers
  end
end
