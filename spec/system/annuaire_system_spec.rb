# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'annuaire', type: :system, js: true do
  let(:user) { create :user, is_admin: true }
  let(:institution) { create :institution }
  let!(:antenne) { create :antenne, institution: institution }
  let!(:another_institution) { create :institution }

  describe 'institutions index' do
    before do
      login_as user, scope: :user
    end

    context 'annuaire/institutions' do
      it 'displays all institution' do
        visit 'annuaire/institutions'

        expect(page).to have_selector 'h1', text: "Institutions"
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        # There is 2 'tr' for institutions and one for headers but FactoryBot create another institution when we create 'antenne'
        expect(page).to have_css('tr', count: 4)
      end
    end

    context '/annuaire/institutions/:slug/domaines' do
      it 'displays all institution subjects' do
        visit "annuaire/institutions/#{institution.slug}/domaines"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
      end
    end

    context '/annuaire/institutions/:slug/antennes' do
      it 'displays all institution antennes' do
        visit "annuaire/institutions/#{institution.slug}/antennes"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('tr', count: 2)
      end
    end

    context '/annuaire/institutions/:slug/antennes/:antenne_id/conseillers' do
      it 'displays all institution antennes' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
      end
    end

    context '/annuaire/institutions/:slug/conseillers' do
      it 'displays all institution users' do
        visit "annuaire/institutions/#{institution.slug}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
      end
    end
  end
end
