require 'rails_helper'
describe PartnerOrigin do
  describe '#from_entreprendre?' do
    subject { described_class.from_entreprendre?(solicitation: solicitation, campaign: campaign, kwd: kwd) }

    let(:solicitation) { nil }
    let(:campaign) { nil }
    let(:kwd) { nil }

    context 'with nil values' do
      it { is_expected.to be(false) }
    end

    context 'with entreprendre campaign' do
      let(:campaign) { 'entreprendre' }

      it { is_expected.to be(true) }
    end

    context 'with not entreprendre campaign' do
      let(:campaign) { 'fructifier' }

      it { is_expected.to be(false) }
    end

    context 'with entreprendre kwd' do
      let(:kwd) { 'F1234' }

      it { is_expected.to be(true) }
    end

    context 'with not entreprendre kwd' do
      let(:kwd) { '123-bois' }

      it { is_expected.to be(false) }
    end

    context 'with solicitation' do
      let(:solicitation) { build :solicitation, cooperation: build(:cooperation, mtm_campaign: 'entreprendre') }

      it { is_expected.to be(true) }
    end
  end
end
