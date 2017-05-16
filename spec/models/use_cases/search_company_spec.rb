# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  describe 'with_siret_and_save' do
    subject(:with_siret_and_save) { described_class.with_siret_and_save siret: siret, user: user }

    let(:siret) { '12345678901234' }
    let(:company_name) { 'Company name' }
    let(:user) { build :user }

    before { allow(described_class).to receive(:with_siret).with(siret) { { 'entreprise' => { 'raison_sociale' => company_name } } } }

    it 'calls another method' do
      with_siret_and_save
      expect(described_class).to have_received(:with_siret).with(siret)
    end

    it 'creates a Search' do
      with_siret_and_save
      expect(Search.last.query).to eq siret
      expect(Search.last.user).to eq user
      expect(Search.last.label).to eq company_name
    end
  end

  describe 'with_siret' do
    let(:siret) { '12345678901234' }
    let(:company_name) { 'Company name' }
    let(:user) { build :user }

    it 'calls external service' do
      allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).with(siret) { { 'entreprise' => { 'raison_sociale' => company_name } } }
      described_class.with_siret siret
      expect(ApiEntrepriseService).to have_received(:fetch_company_with_siret).with(siret)
    end
  end
end
