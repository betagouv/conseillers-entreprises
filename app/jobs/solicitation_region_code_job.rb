# frozen_string_literal: true

class SolicitationRegionCodeJob < ApplicationJob
  def perform(solicitation)
    begin
      etablissement_data = ApiEntreprise::Etablissement::Base.new(solicitation.siret).call
      return if etablissement_data.blank?
      code_region = ApiConsumption::Models::Facility.new(etablissement_data).code_region
      SolicitationModification::Update.call(solicitation, code_region: code_region)
    rescue StandardError => e
      return
    end
  end
end
