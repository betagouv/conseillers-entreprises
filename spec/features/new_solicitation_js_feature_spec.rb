# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

# Tests AVEC js =========================================
# TODO
describe 'New Solicitation', type: :feature, js: true, flaky: true do
  let(:pde_subject) { create :subject }
  let!(:landing) { create :landing, slug: 'accueil', title: 'Test Landing' }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", requires_siret: true }

  describe 'post' do
    let(:solicitation) { Solicitation.last }

    context "from home page" do
      before do
        landing.landing_themes << landing_theme
      end

      xit do
        visit '/'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
        fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
        fill_in 'E-mail', with: 'user@example.com'
        fill_in 'Téléphone', with: '0123456789'
        click_button 'Suivant'
        expect(solicitation.persisted?).to be true
        expect(solicitation.pk_campaign).to be_nil
        expect(solicitation.landing).to eq landing
        expect(solicitation.landing_subject).to eq landing_subject
        expect(solicitation.status_step_company?).to be true

        fill_in 'Votre numéro SIRET', with: '12345678900010'
        fill_in 'solicitation_siret', with: '12345678900010'
        click_button 'Suivant'
        expect(solicitation.reload.siret).to eq '12345678900010'
        expect(solicitation.status_step_description?).to be true

        fill_in 'Description', with: 'Ceci n\'est pas un test'
        click_button 'Envoyer ma demande'
        expect(page).to have_content('Merci')
        expect(solicitation.reload.status_in_progress?).to be true
      end
    end
  end
end
