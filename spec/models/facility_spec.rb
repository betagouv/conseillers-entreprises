# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'validations' do
    subject { create(:facility) }

    it do
      is_expected.to belong_to :company
      is_expected.to validate_presence_of :company
      is_expected.to validate_uniqueness_of(:siret).ignoring_case_sensitivity
      is_expected.to validate_presence_of :commune
    end
  end

  describe 'to_s' do
    subject { facility.to_s }

    let(:facility) { create :facility, readable_locality: '59600 Maubeuge', company: company }
    let(:company) { create :company, name: 'Mc Donalds' }

    it { is_expected.to eq 'Mc Donalds (59600 Maubeuge)' }
  end

  describe '#insee_code=' do
    let(:facility) { build :facility }

    before do
      stub_request(:get, "https://geo.api.gouv.fr/communes/78586?fields=nom,codesPostaux")
        .to_return(body: File.read(Rails.root.join('spec', 'fixtures', 'geo_api_communes_78586.json')))
    end

    it do
      facility.insee_code = '78586'

      expect(facility.readable_locality).to eq '78500 Sartrouville'
    end
  end

  describe 'siret validation' do
    describe 'siret_from_query' do
      subject { described_class.siret_from_query(query) }

      context 'existing valid siret' do
        let(:query) { '82161143100015' }

        it{ is_expected.to eq '82161143100015' }
      end

      context 'nil value' do
        let(:query) { nil }

        it{ is_expected.to be_nil }
      end

      context 'empty value' do
        let(:query) { '' }

        it{ is_expected.to be_nil }
      end

      context 'nonnumeric text' do
        let(:query) { 'some text' }

        it{ is_expected.to be_nil }
      end

      context 'luhn-invalid siret' do
        let(:query) { '82161143100010' }

        it{ is_expected.to be_nil }
      end

      context 'valid siren' do
        let(:query) { '821611431' }

        it{ is_expected.to be_nil }
      end

      context 'special case for La Poste' do
        let(:query) { '35600000012345' }

        it{ is_expected.to eq '35600000012345' }
      end

      context 'valid siret with spaces and separators' do
        let(:query) { ' 821-611_431 0001,5  ' }

        it{ is_expected.to eq '82161143100015' }
      end

      context 'valid siret in text' do
        let(:query) { 'some text, 82161143100015' }

        it{ is_expected.to be_nil }
      end
    end
  end
end
