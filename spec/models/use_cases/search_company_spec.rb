# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
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
