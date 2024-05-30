# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'shared_satisfactions' do
  let(:current_user) { create :user }
  let(:expert) { create :expert, users: [current_user] }
  let(:need1) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
  let(:need2) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
  let(:company_satisfaction1) { create :company_satisfaction, need: need1 }
  let(:company_satisfaction2) { create :company_satisfaction, need: need2 }

  let!(:seen_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction1, user: current_user, seen_at: Time.zone.now }
  let!(:unseen_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction2, user: current_user, seen_at: nil }
  let!(:other_unseen_satisfaction) { create :shared_satisfaction, seen_at: nil }

  before do
    create_home_landing
    login_as current_user, scope: :user
  end

  context 'expert inbox' do
    it 'displays all user shared_satisfactions' do
      visit '/conseiller/retours'
      expect(page).to have_current_path(unseen_conseiller_shared_satisfactions_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      expect(page).to have_content(company_satisfaction2.comment)

      expect(side_menu_link(unseen_conseiller_shared_satisfactions_path)).to have_text('1')
      expect(side_menu_link(seen_conseiller_shared_satisfactions_path)).to have_text('1')

      click_on 'Marquer comme "vu"'

      expect(page).to have_no_css('.fr-card__c-container--need')
      expect(side_menu_link(unseen_conseiller_shared_satisfactions_path)).to have_text('0')
      expect(side_menu_link(seen_conseiller_shared_satisfactions_path)).to have_text('2')

      click_on 'Retours vus'

      expect(page).to have_css('.fr-card__c-container--need', count: 2)
      expect(page).to have_no_button 'Marquer comme "vu"'
    end
  end
end
