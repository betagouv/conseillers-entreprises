# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SearchCompany do
  describe 'with_siret' do
    subject(:with_siret) { described_class.with_siret siret: siret }

    let(:siret) { '12345678901234' }
    let(:company_name) { 'OCTO-TECHNOLOGY' }
    let(:user) { build :user }

    before do
      stub_request(
        :get,
        'https://api.apientreprise.fr/v2/entreprises/123456789?token=1234'
      ).with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      ).to_return(
        status: 200,
        body: File.read(Rails.root.join('spec/responses/api_entreprise.json')),
        headers: {}
      )
    end

    it 'calls external service' do
      subject
    end
  end
end
