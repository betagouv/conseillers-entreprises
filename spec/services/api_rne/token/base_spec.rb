# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe ApiRne::Token::Base do

  ENV['RNE_USERNAME'] = 'François Premier'
  ENV['RNE_PASSWORD'] = 'p4ssw0rd'
  ENV['RNE_USERNAME_2'] = 'Françoise Deux'
  ENV['RNE_PASSWORD_2'] = 'p4ssw0rd'

  let(:token) { described_class.new.call }
  let(:url) { "https://registre-national-entreprises.inpi.fr/api/companies/#{siren}" }

  context 'Identifiants 1 ok' do
    before do
      stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
        .with(body: { username: 'François Premier', password: 'p4ssw0rd' })
        .to_return(
          body: file_fixture('api_rne_token.json')
        )
    end

    it 'returns correct token' do
      expect(token).to eq('123456789')
    end
  end

  context 'Identifiants 1 ko mais 2 ok' do
    before do
      stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
        .with(body: { username: 'François Premier', password: 'p4ssw0rd' })
        .to_return(
          status: 401, body: file_fixture('api_rne_token_401.json')
        )

      stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
        .with(body: { username: 'Françoise Deux', password: 'p4ssw0rd' })
        .to_return(
          body: file_fixture('api_rne_token.json')
        )
    end

    it 'returns correct token' do
      expect(token).to eq('123456789')
    end
  end

  context 'Tous identifiants invalides' do
    let(:siren) { '211703806' }

    before do
      stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
        .with(body: { username: 'François Premier', password: 'p4ssw0rd' })
        .to_return(
          status: 401, body: file_fixture('api_rne_token_401.json')
        )

      stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
        .with(body: { username: 'Françoise Deux', password: 'p4ssw0rd' })
        .to_return(
          status: 401, body: file_fixture('api_rne_token_401.json')
        )
    end

    it 'returns an error' do
      expect(token).to eq({ "rne" => { "error" => "Identifiants invalides." } })
    end
  end
end
