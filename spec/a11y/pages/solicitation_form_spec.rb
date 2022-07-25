# frozen_string_literal: true

require 'rails_helper'

describe 'solicitation_form', type: :feature, js: true do
  subject { page }

  describe 'accessible solicitation form' do
    let(:pde_subject) { create :subject }
    let!(:landing) { create :landing, slug: 'accueil', title: 'Test Landing' }
    let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
    let!(:landing_subject) {
  create :landing_subject, landing_theme: landing_theme, subject: pde_subject,
                                title: "Super sujet", description: "Description LS", requires_siret: true
}

    it do
      # First step
      visit "/aide-entreprise/#{landing.slug}/demande/#{landing_subject.slug}"
      is_expected.to be_accessible
      fill_in 'Prénom et nom', with: 'Mariane'
      fill_in 'E-mail', with: 'user@example.com'
      fill_in 'Téléphone', with: '0123456789'
      click_button 'Suivant'
      # Second step
      is_expected.to be_accessible
      fill_in 'Votre numéro SIRET', with: '12345678900010'
      fill_in 'solicitation_siret', with: '12345678900010'
      click_button 'Suivant'
      # Third step
      is_expected.to be_accessible
      fill_in 'Description', with: 'Ceci n\'est pas un test'
      click_button 'Envoyer ma demande'
      # Thank's step
      is_expected.to be_accessible
    end
  end
end
