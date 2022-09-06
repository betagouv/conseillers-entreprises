# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Models::Facility::ApiInsee do
  describe 'new' do
    let!(:api_model) { described_class.new(params) }

    context 'without params' do
      let(:params) { nil }

      it 'fails silently' do
        expect{ api_model }.not_to raise_error
      end
    end
  end

  describe 'code_region' do
    context '2 caracters departement' do
      let!(:params) {
      {
        "adresseEtablissement" =>
         {
           "complementAdresseEtablissement" => nil,
          "numeroVoieEtablissement" => "22",
          "indiceRepetitionEtablissement" => nil,
          "typeVoieEtablissement" => "CRS",
          "libelleVoieEtablissement" => "GRANDVAL",
          "codePostalEtablissement" => "20000",
          "libelleCommuneEtablissement" => "AJACCIO",
          "libelleCommuneEtrangerEtablissement" => nil,
          "distributionSpecialeEtablissement" => "BP 215",
          "codeCommuneEtablissement" => "2A004",
          "codeCedexEtablissement" => "20187",
          "libelleCedexEtablissement" => "AJACCIO CEDEX 1",
          "codePaysEtrangerEtablissement" => nil,
          "libellePaysEtrangerEtablissement" => nil
         },
      }
    }

      it 'returns correct code region' do
        expect(described_class.new(params).code_region).to eq('94')
      end
    end

    context 'dom-tom departement' do
      let!(:params) {
      {
        "adresseEtablissement" =>
         {
           "complementAdresseEtablissement" => "CTM",
          "numeroVoieEtablissement" => nil,
          "indiceRepetitionEtablissement" => nil,
          "typeVoieEtablissement" => "RUE",
          "libelleVoieEtablissement" => "GASTON DEFFERRE",
          "codePostalEtablissement" => "97200",
          "libelleCommuneEtablissement" => "FORT-DE-FRANCE",
          "libelleCommuneEtrangerEtablissement" => nil,
          "distributionSpecialeEtablissement" => "CS 30137",
          "codeCommuneEtablissement" => "97209",
          "codeCedexEtablissement" => "97261",
          "libelleCedexEtablissement" => "FORT DE FRANCE CEDEX",
          "codePaysEtrangerEtablissement" => nil,
          "libellePaysEtrangerEtablissement" => nil
         },
      }
    }

      it 'returns correct code region' do
        expect(described_class.new(params).code_region).to eq('2')
      end
    end
  end
end
