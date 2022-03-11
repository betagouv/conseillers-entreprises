# frozen_string_literal: true

require 'rails_helper'

describe 'New Solicitation', type: :feature, js: true, flaky: true do
  let(:pde_subject) { create :subject }
  let!(:landing) { create :landing, slug: 'accueil', title: 'Test Landing' }
  let(:landing_theme) { create :landing_theme, title: "Test Landing Theme" }
  let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, subject: pde_subject, title: "Super sujet", description: "Description LS", requires_siret: true }

  describe 'post solicitation' do
    let(:solicitation) { Solicitation.last }

    context "from home page" do
      before do
        landing.landing_themes << landing_theme
      end

      it do
        visit '/'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
        fill_in 'Prénom et nom', with: 'Mariane'
        fill_in 'Téléphone', with: '0123456789'
        fill_in 'Description', with: 'Ceci est un test'
        fill_in 'Votre numéro SIRET', with: '12345678900010'
        fill_in 'E-mail', with: 'user@example.com'
        click_button 'Envoyer ma demande'
        # Only here to avoid flickering test with CI
        find(".section__title", match: :first)
        expect(page).to have_content('Merci')
        expect(solicitation.persisted?).to eq true
        expect(solicitation.landing).to eq landing
        expect(solicitation.siret).to eq '12345678900010'
        expect(solicitation.pk_campaign).to eq nil
      end
    end

    context "from pk campaign" do
      before do
        landing.landing_themes << landing_theme
        visit '/?pk_campaign=FOO&pk_kwd=BAR'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
        # find(".landing-subject-section > div > div.landing-topics > div.landing-topic > h3 > a").click
        fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
        fill_in 'Téléphone', with: '0123456789'
        fill_in 'Description', with: 'Ceci est un test'
        fill_in 'Votre numéro SIRET', with: '12345678900010'
        fill_in 'E-mail', with: 'user@exemple.com'
        click_button 'Envoyer ma demande'
      end

      it do
        # Only here to avoid flickering test with CI
        find(".section__title", match: :first)
        expect(page).to have_content('Merci')
        expect(solicitation.persisted?).to eq true
        expect(solicitation.landing).to eq landing
        expect(solicitation.landing_subject.subject).to eq pde_subject
        expect(solicitation.siret).to eq '12345678900010'
        expect(solicitation.pk_campaign).to eq 'FOO'
        expect(solicitation.pk_kwd).to eq 'BAR'
      end
    end

    context "with siret in url" do
      before do
        landing.landing_themes << landing_theme
        visit '/?siret=12345678900010'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
      end

      it do
        # Only here to avoid flickering test with CI
        expect(page).to have_field('Votre numéro SIRET', with: '12345678900010')
        fill_in 'Prénom et nom', with: 'Hubertine Auclerc'
        fill_in 'Téléphone', with: '0123456789'
        fill_in 'Description', with: 'Ceci est un test'
        fill_in 'E-mail', with: 'user@exemple.com'
        click_button 'Envoyer ma demande'
        find(".section__title", match: :first)
        expect(page).to have_content('Merci')
        expect(solicitation.persisted?).to eq true
        expect(solicitation.landing).to eq landing
        expect(solicitation.landing_subject.subject).to eq pde_subject
        expect(solicitation.siret).to eq '12345678900010'
        expect(solicitation.pk_campaign).to eq nil
      end
    end
  end

  describe 'solicitation with siren' do
    let(:base_url) { 'https://entreprise.api.gouv.fr/v2/entreprises' }

    context 'SIREN number exists' do
      let(:solicitation) { Solicitation.last }
      let(:token) { '1234' }
      let(:siren) { '418166096' }
      let(:url) { "#{base_url}/#{siren}?token=#{token}&context=PlaceDesEntreprises&non_diffusables=false&recipient=PlaceDesEntreprises&object=PlaceDesEntreprises" }

      before do
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, url).to_return(
          body: file_fixture('api_entreprise_get_entreprise.json')
        )
        landing.landing_themes << landing_theme
      end

      xit 'correctly sets siret and code_region' do
        visit '/'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
        fill_in 'Prénom et nom', with: 'Mariane'
        fill_in 'Téléphone', with: '0123456789'
        fill_in 'E-mail', with: 'user@exemple.com'
        fill_in 'Description', with: 'Ceci est un test'
        fill_in 'solicitation-siret', with: '418166096'
        # # option 1 : working in local, not with circle-ci
        # expect(page).to have_content('OCTO-TECHNOLOGY')
        # find(".autocomplete__option", match: :first).click

        # option 2
        option = find(".autocomplete__option")
        expect(option).to have_content('Octo Technology')
        page.execute_script("document.querySelector('.autocomplete__option').click()")

        expect(page).to have_field("solicitation-siret", with: '41816609600051', wait: 2)

        click_button 'Envoyer ma demande'
        find(".section__title", match: :first)
        expect(page).to have_content('Merci')

        expect(solicitation.siret).to eq '41816609600051'
        expect(solicitation.code_region).to eq 11
      end
    end
  end

  describe 'solicitation with fulltext search' do
    let(:base_url) { 'https://entreprise.data.gouv.fr/api/sirene/v1/full_text' }

    context 'choose autocomplete choice' do
      let(:solicitation) { Solicitation.last }
      let(:search) { 'octo technology' }
      let(:url) { "#{base_url}/#{search}" }

      before do
        stub_request(:get, url).to_return(
          body: file_fixture('entreprise_data_gouv_full_text.json')
        )
        landing.landing_themes << landing_theme
      end

      # Not working, for now
      xit 'correctly sets siret and code_region' do
        visit '/'
        click_link 'Test Landing Theme'
        click_link 'Super sujet'
        fill_in 'E-mail', with: 'user@exemple.com'
        fill_in 'Description', with: 'Ceci est un test'
        fill_in 'solicitation-siret', with: 'octo technology'
        option = find(".autocomplete__option")
        expect(option).to have_content('OCTO-TECHNOLOGY')
        # page.execute_script("document.querySelector('.autocomplete__option').click()")
        find(".autocomplete__option", match: :first).click

        expect(page).to have_field("solicitation-siret", with: '41816609600069', wait: 5)

        click_button 'Envoyer ma demande'
        find(".section__title", match: :first)
        expect(page).to have_content('Merci')

        expect(solicitation.siret).to eq '41816609600069'
        expect(solicitation.code_region).to eq 11
      end
    end
  end
end
