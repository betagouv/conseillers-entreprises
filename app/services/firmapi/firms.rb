# frozen_string_literal: true

module Firmapi
  class Firms
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def companies
      @data['companies']
    end
  end
end
