# frozen_string_literal: true

require 'rails_helper'

describe 'New Solicitation Feature', type: :feature, js: true do
  before do
    Rails.cache.clear
    create :landing, slug: 'test-landing', home_sort_order: 0, home_title: 'Test Landing'
  end

  describe 'post solicitation' do
    let(:solicitation) { Solicitation.last }

    before do
      visit '/?pk_campaign=FOO&pk_kwd=BAR'
      click_link 'Test Landing'
      click_link 'Déposer votre demande'

      fill_in 'Description', with: 'Ceci est un test'
      fill_in 'SIRET', with: '123 456 789 00010'
      fill_in 'Téléphone', with: '0123456789'
      fill_in 'Prénom et nom', with: 'User Name'
      fill_in 'Email', with: 'user@exemple.com'
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
