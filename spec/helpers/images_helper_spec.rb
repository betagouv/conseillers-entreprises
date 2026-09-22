require 'rails_helper'

describe ImagesHelper do
  describe 'display_logo' do
    subject { helper.display_logo(name: name, path: path, extra_params: extra_params) }

    let(:extra_params) { {} }

    context 'blank name' do
      let(:name) { '' }
      let(:path) { '' }

      it { is_expected.to be_nil }
    end

    context 'existing institution' do
      let(:name) { 'cci' }
      let(:path) { 'institutions/' }

      it { is_expected.to include 'alt="Cci"' }
    end

    context 'fantasy institution' do
      let(:name) { 'tirlipinpin' }
      let(:path) { 'institutions/' }

      it { is_expected.to be_nil }
    end

    context 'existing institucooperationtion' do
      let(:name) { 'les-aides-cci' }
      let(:path) { 'cooperations/' }

      it { is_expected.to include 'alt="Les aides cci"' }
    end
  end

  describe 'header_picture_tag' do
    subject { helper.header_picture_tag(*args) }

    context 'without argument' do
      let(:args) { [] }

      it { is_expected.to include '/assets/home-430w-', '/assets/home-', '.webp', '.png' }
      it { is_expected.to include 'media="(max-width: 430px)"', 'fetchpriority="high"' }
    end

    context 'with a basename' do
      let(:args) { ['conseillers'] }

      it { is_expected.to include '/assets/conseillers-430w-', '/assets/conseillers-', '.webp', '.png' }
      it { is_expected.not_to include 'home' }
    end
  end
end
