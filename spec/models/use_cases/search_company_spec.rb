# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  let(:siren) { '123456789' }

  describe 'with_siren' do
    let(:token) { '1234' }

    before { ENV['API_ENTREPRISE_TOKEN'] = token }

    it 'calls external service' do
      entreprises_instance = ApiEntreprise::Entreprises.new(token)

      allow(ApiEntreprise::Entreprises).to receive(:new).with(token, { :url_keys => [:entreprises] }) { entreprises_instance }
      allow(entreprises_instance).to receive(:fetch).with(siren)

      described_class.with_siren siren

      expect(ApiEntreprise::Entreprises).to have_received(:new).with(token, { :url_keys => [:entreprises] })
      expect(entreprises_instance).to have_received(:fetch).with(siren)
    end
  end

  describe 'with_siret' do
    it 'calls external service' do
      siret = '12345678901234'
      allow(described_class).to receive(:with_siren).with(siren, { :url_keys => [:entreprises] })

      described_class.with_siret siret

      expect(described_class).to have_received(:with_siren).with(siren, { :url_keys => [:entreprises] })
    end
  end
end
