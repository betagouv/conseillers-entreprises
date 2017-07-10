# frozen_string_literal: true

require 'rails_helper'

describe 'visit feature', type: :feature do
  login_user

  before do
    siret = '12345678901234'
    api_entreprise_fixture = JSON.parse(File.read('./spec/fixtures/api_entreprise_get_entreprise.json'))
    allow(UseCases::SearchCompany).to receive(:with_siret).with(siret) { api_entreprise_fixture }

    visit '/visits'
    expect(page).not_to have_content I18n.t('visits.index.analysis_tool')

    click_link I18n.t('visits.index.new_visit')
    expect(page).to have_content I18n.t('visits.new.new_visit')

    fill_in I18n.t('activerecord.attributes.visit.happened_at'), with: Date.tomorrow
    find('.button#add-company').click
  end

  it { expect(page).to have_content I18n.t('visits.add_company_modal.you_have_two_choices') }
end
