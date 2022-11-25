# frozen_string_literal: true

require 'rails_helper'

describe CompaniesHelper do
  describe 'date_from_timestamp' do
    subject { helper.date_from_timestamp timestamp }

    context 'first timestamp' do
      let(:timestamp) { 0 }

      it { is_expected.to eq '01/01/1970' }
    end

    context 'timestamp at midnight' do
      let(:timestamp) { 1_506_808_800 }

      it { is_expected.to eq '01/10/2017' }
    end

    context 'negative timestamp' do
      let(:timestamp) { -50_000 }

      it { is_expected.to eq '31/12/1969' }
    end

    context 'string timestamp' do
      let(:timestamp) { '100' }

      it { is_expected.to eq '01/01/1970' }
    end

    context 'nil timestamp' do
      let(:timestamp) { nil }

      it { is_expected.to be_nil }
    end

    context '“Donnée indisponible” timestamp' do
      let(:timestamp) { 'Donnée indisponible' }

      it { is_expected.to be_nil }
    end
  end
end
