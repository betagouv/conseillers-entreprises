# frozen_string_literal: true

require 'rails_helper'
describe FormatSiret do
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
