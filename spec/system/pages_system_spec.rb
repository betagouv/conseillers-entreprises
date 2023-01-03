# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'Pages' do
  before do
    create_home_landing
    # todo : tester empahsis + page contactez-nous ?
    create_base_dummy_data
  end

  it 'navigates public pages' do
    visit '/'

    find("a[href='#{comment_ca_marche_path}']", match: :first).click
    expect(page).to have_content "Questions fréquentes"
    expect(page).to have_selector '.faq', count: 4
    advisors_count = User.all.distinct.count
    needs_count = Need.diagnosis_completed.count
    companies_count = Company.includes(:needs).references(:needs).where(facilities: { diagnoses: { step: :completed } }).distinct.count
    expect(page).to have_content(advisors_count)
    expect(page).to have_content(needs_count)
    expect(page).to have_content(companies_count)

    click_link 'Accès conseillers'
    click_link 'Tutoriel'
    click_link 'Chefs d’entreprises, cliquez ici'

    click_link 'Conditions d’utilisation'
    click_link 'Mentions d\'information'
    click_link 'Mentions légales'
    click_link 'Accessibilité : partiellement conforme'
    click_link 'Statistiques'
    expect(page).to have_select 'territory'
    expect(page).not_to have_select 'institution'
    find_by_id('start_date').set "2021-03-01"
    click_button 'Filtrer'
    expect(page).to have_select 'territory'
    click_link 'Plan du site'
    expect(page).to have_content(Landing.first.title)
  end
end
