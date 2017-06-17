# frozen_string_literal: true

require 'rails_helper'

describe 'visit feature', type: :feature do
  login_user

  before do
    api_entreprise_fixture = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
    allow(ApiEntrepriseService).to receive(:fetch_company_with_siret).at_least(:once) { api_entreprise_fixture }

    visit '/visits'
    expect(page).not_to have_content 'Analyse'

    click_link 'Nouvelle visite'
    expect(page).to have_content 'Nouvelle visite'
    fill_in 'Date de la visite', with: Date.tomorrow
  end

  it {}
end
