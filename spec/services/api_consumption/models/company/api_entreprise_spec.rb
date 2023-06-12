# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Models::Company::ApiEntreprise do
  describe 'new' do
    let!(:api_model) { described_class.new(params) }

    context 'without params' do
      let(:params) { nil }

      it 'fails silently' do
        expect{ api_model }.not_to raise_error
      end
    end
  end

  describe 'activite_liberale' do
    context 'forme_exercice liberal' do
      let!(:params) do
        {
          forme_juridique: {
            code: "5710",
            libelle: "SAS, société par actions simplifiée"
          },
          activite_principale: {
            code: "62.02A",
            nomenclature: "NAFRev2",
            libelle: "Conseil en systèmes et logiciels informatiques"
          },
          forme_exercice: "INDEPENDANTE"
        }
      end

      it 'returns true activite_liberale' do
        expect(described_class.new(params).activite_liberale).to be(true)
      end
    end

    context 'forme_exercice non liberal, naf liberal' do
      let!(:params) do
        {
          forme_juridique: {
            code: "1000",
            libelle: "Entrepreneur individuel"
          },
          activite_principale: {
            code: "02.40Z",
            nomenclature: "NAFRev2",
            libelle: "Services de soutien à l’exploitation forestière"
          },
          forme_exercice: nil
        }
      end

      it 'returns true activite_liberale' do
        expect(described_class.new(params).activite_liberale).to be(true)
      end
    end

    context 'no liberal data' do
      let!(:params) do
        {
          forme_juridique: {
            code: "5710",
            libelle: "SAS, société par actions simplifiée"
          },
          activite_principale: {
            code: "62.02A",
            nomenclature: "NAFRev2",
            libelle: "Conseil en systèmes et logiciels informatiques"
          },
          forme_exercice: "COMMERCIALE"
        }
      end

      it 'returns false activite_liberale' do
        expect(described_class.new(params).activite_liberale).to be(false)
      end
    end
  end
end
