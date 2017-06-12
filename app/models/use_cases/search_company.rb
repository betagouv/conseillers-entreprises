# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret_and_save(siret:, user:)
        company = ApiEntreprise::Company.from_siret siret
        return unless company.present?
        Search.create! query: siret, user: user, label: company.entreprise.raison_sociale
      end
    end
  end
end
