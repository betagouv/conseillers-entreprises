# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchFilter do
  describe 'getter' do
    subject { match_filter.raw_accepted_naf_codes }

    let(:match_filter) { create :match_filter, accepted_naf_codes: accepted_naf_codes }

    context 'with full accepted_naf_codes' do
      let(:accepted_naf_codes) { ["9001Z", "9002Z"] }

      it { is_expected.to eq "9001Z 9002Z" }
    end

    context 'with empty accepted_naf_codes' do
      let(:accepted_naf_codes) { [] }

      it { is_expected.to eq '' }
    end
  end

  describe 'setter' do
    subject { match_filter.accepted_naf_codes }

    let(:match_filter) { create :match_filter, raw_accepted_naf_codes: raw_accepted_naf_codes }

    context 'with empty data' do
      let(:raw_accepted_naf_codes) { '' }

      it { is_expected.to eq [] }
    end

    context 'with proper values' do
      let(:raw_accepted_naf_codes) { '90.01Z 9002Z' }

      it { is_expected.to eq ["9001Z", "9002Z"] }
    end

  end
end
