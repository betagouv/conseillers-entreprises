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
  let(:siret) { '41816609600069' }
  let(:siren) { siret[0..8] }
  let(:solicitation) { Solicitation.last }

  describe 'create' do
    before do
      landing.landing_themes << landing_theme
    end

    context "with API calls" do
      before do
        authorize_insee_token
        stub_request(:get, api_url).to_return(
          body: file_fixture(fixture_file)
        )
      end

      # Features tests sont coûteux, je tests deux éléments indépendants dans un test
      context "from siret, with additional_subject_questions in url" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret.json' }
        let(:query) { siret }
        let!(:additional_question_1) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_poste_cadre' }
        let!(:additional_question_2) { create :additional_subject_question, subject: pde_subject, key: 'recrutement_en_apprentissage' }

        it do
          visit '/?recrutement_poste_cadre=true&recrutement_en_apprentissage=false'
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

          fill_in 'Recherchez votre entreprise', with: query
          option = find(".autocomplete__option", match: :first)
          expect(option).to have_content('Octo Technology')
          page.execute_script("document.querySelector('.autocomplete__option').click()")
          click_button 'Suivant'

          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true

          fill_in 'Description', with: 'Ceci n\'est pas un test'
          # radio button sur 'Oui' pour recrutement_poste_cadre
          expect(page).to have_field('solicitation_institution_filters_attributes_0_filter_value_true', checked: true)
          expect(page).to have_field('solicitation_institution_filters_attributes_0_filter_value_false', checked: false)
          # radio button sur 'Non' pour recrutement_en_apprentissage
          expect(page).to have_field("solicitation_institution_filters_attributes_1_filter_value_true", checked: false)
          expect(page).to have_field("solicitation_institution_filters_attributes_1_filter_value_false", checked: true)

          click_button 'Envoyer ma demande'
          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "from siren" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siren:#{query}" }
        let(:fixture_file) { 'api_insee_sirets_by_siren_many.json' }
        let(:query) { siren }

        it do
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

          fill_in 'Recherchez votre entreprise', with: query
          option = find(".autocomplete__option", match: :first)
          expect(option).to have_content('Octo Technology')
          page.execute_script("document.querySelector('.autocomplete__option').click()")
          click_button 'Suivant'

          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true

          fill_in 'Description', with: 'Ceci n\'est pas un test'
          click_button 'Envoyer ma demande'
          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "from fulltext" do
        let(:api_url) { "https://recherche-entreprises.api.gouv.fr/search?q=#{query}" }
        let(:fixture_file) { 'api_recherche_entreprises_search.json' }
        let(:query) { 'octo technology' }

        before do
          # additional api call
          stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siren:#{siren}").to_return(
            body: file_fixture('api_insee_sirets_by_siren_many.json')
          )
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

          fill_in 'Recherchez votre entreprise', with: query
          click_button 'Rechercher'
          expect(page).to have_content('Sélectionnez votre entreprise :')
          click_button "#{siren} - Octo Technology"

          expect(page).to have_content("Sélectionnez l'établissement concerné :")
          click_button "#{siret} - Octo Technology"

          expect(solicitation.reload.siret).to eq siret
          expect(solicitation.code_region).to eq 11
          expect(solicitation.status_step_description?).to be true

          fill_in 'Description', with: 'Ceci n\'est pas un test'
          click_button 'Envoyer ma demande'
          expect(page).to have_content('Merci')
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "manual siret" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret.json' }
        let(:query) { '41816609600069' }
        let(:entreprise_api_url) { "https://entreprise.api.gouv.fr/v2/etablissements/#{query}?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

        before do
          stub_request(:get, "https://recherche-entreprises.api.gouv.fr/search?q=toto")
            .to_return(status: 200, body: '{"results": []}', headers: {})
          ENV['API_ENTREPRISE_TOKEN'] = '1234'
          stub_request(:get, entreprise_api_url).to_return(
            body: file_fixture('api_entreprise_get_etablissement.json')
          )
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

          fill_in 'Recherchez votre entreprise', with: 'toto'
          click_button 'Rechercher'
          expect(page).to have_content('Sélectionnez votre entreprise :')

          click_link "Je ne trouve pas mon entreprise"
          fill_in 'Votre numéro SIRET', with: "n'importe quoi"
          click_button 'Suivant'
          expect(page).to have_content('SIRET doit être un numéro à 14 chiffres')
          expect(solicitation.reload.siret).to be_nil

          fill_in 'Votre numéro SIRET', with: "418 166 096 00069"
          click_button 'Suivant'
          expect(solicitation.reload.siret).to eq "41816609600069"
          expect(solicitation.code_region).to be_nil
          expect(solicitation.status_step_description?).to be true

          fill_in 'Description', with: 'Ceci n\'est pas un test'
          click_button 'Envoyer ma demande'
          expect(page).to have_content('Merci')
          expect(solicitation.reload.code_region).to eq 11
          expect(solicitation.reload.status_in_progress?).to be true
        end
      end

      context "with api error" do
        let(:api_url) { "https://api.insee.fr/entreprises/sirene/V3/siret/?q=siret:#{query}" }
        let(:fixture_file) { 'api_insee_siret_400.json' }
        let(:query) { 'tata yoyo' }

        xit do
          visit '/'
          click_link 'Test Landing Theme'
          click_link 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'E-mail', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_button 'Suivant'
          expect(solicitation.persisted?).to be true

          fill_in 'Recherchez votre entreprise', with: '40440440440400'
          click_button 'Rechercher'
          expect(page).not_to have_content('Sélectionnez votre entreprise :')

          expect(page).to have_content("L'identifiant (siret ou siren) est invalide")
        end
      end
    end

    context "no API calls" do
      context "with PK params in url" do
        xit do
          visit '/?pk_campaign=FOO&pk_kwd=BAR'
          click_link 'Test Landing Theme'
          click_link 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'E-mail', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_button 'Suivant'
          expect(solicitation.persisted?).to be true
          expect(solicitation.pk_campaign).to eq 'FOO'
          expect(solicitation.pk_kwd).to eq 'BAR'
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.status_step_company?).to be true
        end
      end

      context "with siret in url" do
        let(:siret) { "41816609600077" }

        xit do
          visit "/?siret=#{siret}"
          click_link 'Test Landing Theme'
          click_link 'Super sujet'
          fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
          fill_in 'E-mail', with: 'user@example.com'
          fill_in 'Téléphone', with: '0123456789'
          click_button 'Suivant'
          expect(solicitation.persisted?).to be true
          expect(solicitation.landing).to eq landing
          expect(solicitation.landing_subject).to eq landing_subject
          expect(solicitation.siret).to eq siret
          expect(solicitation.pk_campaign).to be_nil
          expect(solicitation.status_step_company?).to be true
        end
      end
    end
  end
end
