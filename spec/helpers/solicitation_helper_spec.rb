# frozen_string_literal: true

require 'rails_helper'

describe SolicitationHelper do
  describe 'display_region' do
    context 'without region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, nil) }

      it 'return region' do
        is_expected.to eq "<li class=\"item\">#{CGI.unescapeHTML(I18n.t('helpers.solicitation.localisation_html', region: region.name))}</li>"
      end
    end

    context 'with region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, 'Region Bretagne') }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end

    context 'without region for solicitation' do
      let(:region) { nil }

      subject { helper.display_region(region, nil) }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end
  end

  # Affiché dans la page besoin
  describe 'partner_title' do
    let(:cooperation) { create :cooperation, root_url: 'https://exemple.fr' }

    subject { helper.partner_title(solicitation) }

    context 'entreprendre solicitation' do
      let(:solicitation) { create :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111', cooperation: cooperation }

      it { is_expected.to eq "https://entreprendre.service-public.fr/vosdroits/F1111" }
    end

    context 'with landing url' do
      let(:solicitation) { create :solicitation, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

      it { is_expected.to eq 'https://exemple.fr' }
    end

    context 'with origin_url' do
      let(:solicitation) { create :solicitation, form_info: { "origin_url" => "https://exemple-bis.fr/super-aide", "origin_title" => "Super aide" }, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

      it { is_expected.to eq "Super aide (https://exemple.fr)" }
    end
  end

  describe 'partner_url' do
    subject { helper.partner_url(solicitation, full: full) }

    let(:cooperation) { create :cooperation, root_url: 'https://exemple.fr' }

    context 'without full display' do
      let(:full) { false }

      context 'entreprendre solicitation' do
        let(:solicitation) { create :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111' }

        it { is_expected.to eq "https://entreprendre.service-public.fr/vosdroits/F1111" }
      end

      context 'with landing url' do
        let(:solicitation) { create :solicitation, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

        it { is_expected.to eq 'https://exemple.fr' }
      end

      context 'with origin_url' do
        let(:solicitation) { create :solicitation, form_info: { "origin_url" => "exemple.fr/super-aide", "origin_title" => "Super aide" }, landing: create(:landing, url_path: '/aide-1') }

        it { is_expected.to eq "exemple.fr/super-aide" }
      end
    end

    context 'with full display' do
      let(:full) { true }

      context 'entreprendre solicitation' do
        let(:solicitation) { create :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111' }

        it { is_expected.to eq "https://entreprendre.service-public.fr/vosdroits/F1111" }
      end

      context 'with landing url' do
        let(:solicitation) { create :solicitation, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

        it { is_expected.to eq 'https://exemple.fr/aide-1' }
      end

      context 'with origin_url' do
        let(:solicitation) { create :solicitation, form_info: { "origin_url" => "exemple-bis.fr/super-aide", "origin_title" => "Super aide" }, landing: create(:landing, cooperation: cooperation, url_path: '/aide-1') }

        it { is_expected.to eq "exemple-bis.fr/super-aide" }
      end
    end

  end
end
