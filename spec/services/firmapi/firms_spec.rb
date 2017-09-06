# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Firmapi::Firms do
  describe 'parsed_companies' do
    subject { described_class.new(data).parsed_companies }

    context 'denomination is nil' do
      let(:data) { JSON.parse(File.read(Rails.root.join('spec/fixtures/firmapi_get_firms.json'))) }

      expected_json = [
        { siren: '810579037', name: 'Octra', location: '75002 Paris' },
        { siren: '418166096', name: 'Octo Technology', location: '75008 Paris' }
      ]

      it { is_expected.to eq expected_json }
    end
  end

  describe 'name' do
    subject { described_class.name(company) }

    let(:company) { { 'names' => { 'best' => best, 'denomination' => denomination } } }
    let(:best) { 'Octo Technology' }

    context 'denomination is nil' do
      let(:denomination) { nil }

      it { is_expected.to eq best }
    end

    context 'best and denomination are the same' do
      let(:denomination) { 'OCTO TECHNOLOGY' }

      it { is_expected.to eq best }
    end

    context 'best and denomination are the same once titleized' do
      let(:denomination) { 'OCTO-TECHNOLOGY' }

      it { is_expected.to eq best }
    end

    context 'best and denomination are different' do
      let(:denomination) { 'Octo' }

      it { is_expected.to eq 'Octo Technology (Octo)' }
    end
  end

  describe 'location' do
    subject { described_class.location(company) }

    let(:company) { { 'postal_code' => '59123', 'city' => 'Meubauge' } }

    it { is_expected.to eq '59123 Meubauge' }
  end
end
