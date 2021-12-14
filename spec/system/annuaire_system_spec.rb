# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'annuaire', type: :system, js: true, flaky: true do
  let(:user) { create :user, role: 'admin' }
  let(:institution) { create :institution }
  let!(:antenne) { create :antenne, institution: institution }
  let!(:another_institution) { create :institution }

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
    let!(:expert) { create :expert, antenne: antenne }
    let!(:user_1) { create :user, experts: [expert], antenne: antenne }

    describe 'one expert with institution_subject' do
      let!(:institution_subject) { create :institution_subject, institution: institution }
      let!(:expert_subject) { create :expert_subject, institution_subject: institution_subject, expert: expert }

      it 'display users without warning' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('.td-header.td-user', count: 1)
        expect(page).to have_css('.red.ri-error-warning-fill', count: 0)
      end
    end

    describe 'many experts on institution_subject' do
      let!(:institution_subject) { create :institution_subject, institution: institution }
      let!(:expert_subject) { create :expert_subject, institution_subject: institution_subject, expert: expert }
      let!(:expert_subject_2) { create :expert_subject, institution_subject: institution_subject, expert: expert_2 }
      let!(:expert_2) { create :expert, antenne: antenne }
      let!(:user_2) { create :user, experts: [expert_2], antenne: antenne }

      it 'display users with orange warning' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('.td-header.td-user', count: 2)
        expect(page).to have_css('.orange.ri-error-warning-fill', count: 1)
        expect(page).to have_css('.red.ri-error-warning-fill', count: 0)
        expect(page).to have_css('.yellow', count: 2)
      end
    end

    describe 'expert without institution_subject' do
      let!(:institution_subject) { create :institution_subject, institution: institution }

      it 'display users with red warning' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('.td-header.td-user', count: 1)
        expect(page).to have_css('.red.ri-error-warning-fill', count: 1)
        expect(page).to have_css('.yellow', count: 0)
      end
    end

    describe 'optional institution_subject' do
      let!(:optional_institution_subject) { create :institution_subject, institution: institution, optional: true }

      it 'display users without warning for optional institution subjects' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

        expect(page).to have_selector 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('.td-header.td-user', count: 1)
        expect(page).to have_css('.red.ri-error-warning-fill', count: 0)
        expect(page).to have_css('.yellow', count: 0)
      end
    end
  end
end
