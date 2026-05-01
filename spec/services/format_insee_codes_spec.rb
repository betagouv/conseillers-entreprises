require 'rails_helper'

RSpec.describe FormatInseeCodes do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context 'with 5-digit codes' do
      let(:input) { '75056 69123' }

      it { is_expected.to eq '75056 69123' }
    end

    context 'with a 4-digit code (zero-padded)' do
      let(:input) { '1234' }

      it { is_expected.to eq '01234' }
    end

    context 'with mixed 4-digit and 5-digit codes' do
      let(:input) { '1234 75056' }

      it { is_expected.to eq '01234 75056' }
    end

    context 'with empty string' do
      let(:input) { '' }

      it { is_expected.to eq '' }
    end
  end
end
