# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe Api::FranceCompetence::Siret::Base do
  let(:api) { described_class.new(siret).call }
  let(:url) { "https://api.francecompetences.fr/siropartfc/v1/api/partenaire/#{siret}" }

  context 'SIRET reconnu' do
    let(:siret) { '41816609600069' }

    before do
      authorize_france_competence_token
      stub_france_competence_siret(url, file_fixture('api_france_competence_siret.json'))
    end

    it 'returns company forme_exercice' do
      expect(api['opco_fc']['opcoRattachement']).to eq({ "code" => "03", "nom" => "ATLAS" })
    end
  end

  context 'SIRET non reconnu' do
    let(:siret) { '89448692700011' }

    before do
      authorize_france_competence_token
      stub_france_competence_siret(url, file_fixture('api_france_competence_siret_99.json'))
    end

    it 'returns an error' do
      expect(api['opco_fc']).to eq("error" => "Siret Not Found")
    end
  end

  context 'Erreur 500' do
    let(:siret) { '89448692700011' }

    before do
      authorize_france_competence_token
      stub_france_competence_siret(url, { erreur: 'xstz' }.to_json, 500)
    end

    it 'returns a technical error' do
      expect(api['opco_fc']).to eq("error" => "Nous n’avons pas pu récupérer les données entreprises auprès de nos partenaires. Notre équipe technique en a été informée, veuillez réessayer ultérieurement.")
    end
  end
end
