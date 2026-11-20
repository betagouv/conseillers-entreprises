require 'rails_helper'

RSpec.describe 'shared/_maintenance_banner' do
  before do
    without_partial_double_verification do
      allow(view).to receive_messages(maintenance_banner_title: title, in_iframe?: in_iframe)
    end
    render partial: 'shared/maintenance_banner'
  end

  let(:in_iframe) { false }

  context 'with a maintenance planned' do
    let(:title) { 'Maintenance prévue le vendredi 27 novembre 2026 de 18h00 à 20h00.' }

    it 'shows the title and the consequence' do
      expect(rendered).to have_css('.fr-notice.fr-notice--warning .fr-notice__title', text: title)
      expect(rendered).to have_css('.fr-notice__desc', text: 'Le service sera momentanément indisponible.')
    end

    context 'in an iframe' do
      let(:in_iframe) { true }

      it { expect(rendered).to have_no_css('.fr-notice') }
    end
  end

  context 'without a maintenance planned' do
    let(:title) { nil }

    it { expect(rendered).to have_no_css('.fr-notice') }
  end
end
