# frozen_string_literal: true

require 'rails_helper'

describe 'visit feature', type: :feature do
  login_user

  before do
    api_entreprise_fixture = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
    allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).at_least(:once) { api_entreprise_fixture }

    visit '/visits'

    expect(page).not_to have_content 'SIRET de l\'entreprise'

    click_link 'Info Entreprises'

    expect(page).to have_content 'Entreprises'
    within '#company-siret-search-form' do
      fill_in id: 'siret-field', with: '41816609600051'
      click_button 'Rechercher'
    end

    expect(page).to have_content 'Nouvelle visite'
    fill_in 'Date de la visite', with: Date.tomorrow
    click_button 'Enregistrer'
  end

  it 'redirects to new_visit' do
    expect(page).to have_content 'Résultat pour le SIRET 41816609600051'
  end
end
