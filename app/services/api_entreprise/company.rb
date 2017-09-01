# frozen_string_literal: true

module ApiEntreprise
  class Company
    attr_reader :entreprise, :etablissement_siege

    def initialize(company_h)
      return if company_h.blank?
      @entreprise = OpenStruct.new(company_h.fetch('entreprise', {}))
      @etablissement_siege = OpenStruct.new(company_h.fetch('etablissement_siege', {}))
    end

    def self.from_siret(siret)
      siret = siret[0..8]
      new Request.new(siret).process
    end
  end
end
