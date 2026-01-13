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

  describe 'partner_url' do
    subject { described_class.partner_url(solicitation, full: full) }

    let(:cooperation) { build :cooperation, root_url: 'https://exemple.fr' }

    context 'without full display' do
      let(:full) { false }

      context 'entreprendre solicitation' do
        let(:solicitation) { build :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111' }

        it { is_expected.to eq "https://entreprendre.service-public.gouv.fr" }
      end

      context 'with landing url' do
        let(:solicitation) do
          build :solicitation,
                landing: build(:landing, cooperation: cooperation, url_path: '/aide-1')
        end

        it { is_expected.to eq 'https://exemple.fr' }
      end

      context 'with origin_url' do
        let(:solicitation) do
          build :solicitation, form_info: { "origin_url" => "exemple.fr/super-aide", "origin_title" => "Super aide" },
                           landing: build(:landing, url_path: '/aide-1')
        end

        it { is_expected.to eq "exemple.fr/super-aide" }
      end
    end

    context 'with full display' do
      let(:full) { true }

      context 'partenaire entreprendre' do
        let(:solicitation) { build :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111' }

        it { is_expected.to eq "https://entreprendre.service-public.gouv.fr/vosdroits/F1111" }
      end

      context 'with landing url' do
        let(:solicitation) { build :solicitation, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

        it { is_expected.to eq 'https://exemple.fr/aide-1' }
      end

      context 'with origin_url' do
        let(:solicitation) do
          build :solicitation, form_info: { "origin_url" => "exemple-bis.fr/super-aide", "origin_title" => "Super aide" },
                           landing: build(:landing, cooperation: cooperation, url_path: '/aide-1')
        end

        it { is_expected.to eq "exemple-bis.fr/super-aide" }
      end
    end
  end
end
