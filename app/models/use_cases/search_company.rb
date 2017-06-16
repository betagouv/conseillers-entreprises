# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret(siret)
        company = ApiEntreprise::Company.from_siret siret
        return unless company.present?
      end
    end
  end
end
