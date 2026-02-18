require 'rails_helper'
require 'api_helper'

# Tests SANS js =========================================

describe 'New Solicitation' do
  let(:pde_subject) { create :subject }
  let!(:landing) { create :landing, slug: 'accueil', title: 'Accueil' }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", fields_mode: :siret }
  let(:siret) { '41816609600069' }
  let(:siren) { siret[0..8] }
  let(:solicitation) { Solicitation.last }

  describe 'create' do
    before do
      landing.landing_themes << landing_theme
    end

    context "no API calls" do
      context "with PK params in url" do
        before do
          visit '/?pk_campaign=FOO&pk_kwd=BAR'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_on 'Suivant'
        end

        it do
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to eq 'FOO'
          expect(solicitation.pk_kwd).to eq 'BAR'
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.status_step_company?).to be true
        end
      end

      context "with MTM params in url" do
        before do
          visit '/?mtm_campaign=FOO&mtm_kwd=BAR'
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'Téléphone', with: '0123456789'
          fill_in 'Email', with: 'user@exemple.com'
          click_on 'Suivant'
        end

        it do
          expect(solicitation.persisted?).to be true
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject.subject).to eq pde_subject
          expect(solicitation.mtm_campaign).to eq 'FOO'
          expect(solicitation.mtm_kwd).to eq 'BAR'
        end
      end

      context "with prefilled params in url" do
        let(:full_name) { "Ada Lovelace" }
        let(:email) { "ada@lovelace.com" }
        let(:phone_number) { "0101010101" }
        let(:siret) { "41816609600069" }

        before do
          visit "/?siret=#{siret}&email=#{email}&full_name=#{full_name}&phone_number=#{phone_number}"
          click_on 'Test Landing Theme', match: :first
          click_on 'Super sujet'

        end

        it do
          # Les champs sont pré-remplis par les params
          expect(page).to have_field('solicitation_full_name', with: full_name)
          expect(page).to have_field('solicitation_email', with: email)
          expect(page).to have_field('solicitation_phone_number', with: phone_number)
          click_on 'Suivant'

          expect(solicitation.persisted?).to be true
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.full_name).to eq full_name
          expect(solicitation.email).to eq email
          expect(solicitation.phone_number).to eq phone_number
          expect(solicitation.siret).to eq siret
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.mtm_campaign).to be_nil
          expect(solicitation.status_step_company?).to be true

          # Les champs sont pré-remplis par les valeurs persistés
          click_on 'Précédent'
          expect(page).to have_field('solicitation_full_name', with: full_name)
          expect(page).to have_field('solicitation_email', with: email)
          expect(page).to have_field('solicitation_phone_number', with: phone_number)
        end
      end
    end
  end
end
