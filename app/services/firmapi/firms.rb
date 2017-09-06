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

    def parsed_companies
      companies.map do |company|
        {
          siren: company['siren'],
          name: Firms.name(company),
          location: Firms.location(company)
        }
      end
    end

    class << self
      def name(company)
        names = company['names']
        best_name = names['best']
        denomination = names['denomination'].presence
        if denomination && best_name.casecmp(denomination) != 0 && best_name.casecmp(denomination.titleize) != 0
          "#{best_name} (#{denomination.titleize})"
        else
          best_name
        end
      end

      def location(company)
        "#{company['postal_code']} #{company['city']}"
      end
    end
  end
end
