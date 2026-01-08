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
      let(:solicitation) { instance_double(Solicitation, cooperation: instance_double(Cooperation, mtm_campaign: 'entreprendre')) }

      it { is_expected.to be(true) }
    end
  end

  describe '#entreprendre_url' do
    subject { described_class.entreprendre_url(solicitation, full: full) }

    let(:solicitation) { nil }
    let(:full) { nil }

    context 'with nil values' do
      it { is_expected.to eq("https://entreprendre.service-public.gouv.fr") }
    end

    context 'full with entreprendre page kwd' do
      let(:solicitation) { instance_double(Solicitation, kwd: "F1234") }
      let(:full) { true }

      it { is_expected.to eq("https://entreprendre.service-public.gouv.fr/vosdroits/F1234") }
    end

    context 'full with other kwd' do
      let(:solicitation) { instance_double(Solicitation, kwd: "accueil") }
      let(:full) { true }

      it { is_expected.to eq("https://entreprendre.service-public.gouv.fr") }
    end
  end

  describe "#landing_partner_url" do
    let(:landing) { instance_double(Landing, partner_url: "https://example.com", partner_full_url: "https://example.com/long_path") }
    let(:solicitation) { instance_double(Solicitation, landing: landing) }

    subject { described_class.landing_partner_url(solicitation, full: full) }

    context 'full' do
      let(:full) { true }

      it { is_expected.to eq("https://example.com/long_path") }
    end

    context 'short' do
      let(:full) { false }

      it { is_expected.to eq("https://example.com") }
    end
  end
end
