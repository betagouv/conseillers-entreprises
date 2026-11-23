require 'rails_helper'

RSpec.describe 'shared/_maintenance_banner' do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FEATURE_MAINTENANCE_BANNER_TITLE').and_return(title)
    allow(ENV).to receive(:[]).with('FEATURE_MAINTENANCE_BANNER_DESCRIPTION').and_return(description)
    without_partial_double_verification do
      allow(view).to receive(:in_iframe?).and_return(in_iframe)
    end
    render partial: 'shared/maintenance_banner'
  end

  let(:in_iframe) { false }
  let(:title) { 'Maintenance prévue le vendredi 27 novembre de 18h à 20h.' }
  let(:description) { 'Le service sera momentanément indisponible.' }

  context 'with a title and a description' do
    it do
      expect(rendered).to have_css('.fr-notice.fr-notice--warning .fr-notice__title', text: title)
      expect(rendered).to have_css('.fr-notice__desc', text: description)
    end

    context 'in an iframe' do
      let(:in_iframe) { true }

      it { expect(rendered).to have_no_css('.fr-notice') }
    end
  end

  context 'with a title only' do
    let(:description) { nil }

    it do
      expect(rendered).to have_css('.fr-notice__title', text: title)
      expect(rendered).to have_no_css('.fr-notice__desc')
    end
  end

  context 'with a description only' do
    let(:title) { '' }

    it do
      expect(rendered).to have_css('.fr-notice__desc', text: description)
      expect(rendered).to have_no_css('.fr-notice__title')
    end
  end

  context 'without any text' do
    let(:title) { '' }
    let(:description) { nil }

    it { expect(rendered).to have_no_css('.fr-notice') }
  end
end
