# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe ApiFranceCompetence::Siret::Base do
  let(:api_opco) { described_class.new(siret).call }
  let(:url) { "https://api-preprod.francecompetences.fr/siropartfc/#{siret}" }

  context 'SIRET reconnu' do
    let(:siret) { '41816609600069' }

    before do
      authorize_france_competence_token
      stub_france_competence_siret(url, file_fixture('api_france_competence_siret.json'))
    end

    it 'returns company forme_exercice' do
      expect(api_opco['opco_fc']['opcoRattachement']).to eq({ "code" => "03", "nom" => "ATLAS" })
    end
  end

  context 'SIRET non reconnu' do
    let(:siret) { '89448692700011' }

    before do
      authorize_france_competence_token
      stub_france_competence_siret(url, file_fixture('api_france_competence_siret_99.json'))
    end

    it 'returns an error' do
      expect(api_opco['opco_fc']).to eq("error" => "Siret Not Found")
    end
  end
end
