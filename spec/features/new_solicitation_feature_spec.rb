# frozen_string_literal: true

require 'rails_helper'

describe 'New Solicitation Feature', type: :feature, js: true do
  let(:landing) { create :landing, slug: 'test-landing', home_sort_order: 0, home_title: 'Test Landing' }
  let(:landing_option) { create :landing_option, landing: landing, requires_siret: true, requires_email: true }
  let(:landing_topic) { create :landing_topic, title: 'landing topic test', landing: landing, landing_option_slug: landing_option.slug }

  before do
    Rails.cache.clear
    landing_topic
  end

  describe 'post solicitation' do
    let(:solicitation) { Solicitation.last }

    before do
      visit '/?pk_campaign=FOO&pk_kwd=BAR'
      click_link 'Test Landing'
      # Find 'Choose' link
      find("#section-exemples > div > div.landing-topics > div > a").click

      fill_in 'Description', with: 'Ceci est un test'
      fill_in 'SIRET', with: '123 456 789 00010'
      fill_in 'E-mail', with: 'user@exemple.com'
      click_button 'Envoyer ma demande'
    end

    it do
      expect(page).to have_content('Merci')
      expect(solicitation.landing_slug).to eq 'test-landing'
      expect(solicitation.siret).to eq '123 456 789 00010'
      expect(solicitation.pk_campaign).to eq 'FOO'
      expect(solicitation.pk_kwd).to eq 'BAR'
    end
  end
end
