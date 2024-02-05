# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'needs' do
  let(:user) { create :user, :manager }
  let(:managed_antenne_01) { user.antenne }
  let!(:current_expert) { create :expert, antenne: managed_antenne_01, users: [user] }
  let(:diagnosis) { create :diagnosis_completed }

  let!(:need_quo) do
    create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
  end

  before do
    create_home_landing
    login_as user, scope: :user
  end

  context 'expert inbox' do
    it 'displays all user received needs pages' do
      visit '/'
      click_on 'Accès conseillers'
      click_on 'Demandes reçues'
      expect(page).to have_current_path(quo_active_needs_path, ignore_query: true)
      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      expect(side_menu_link(quo_active_needs_path)).to have_text('1')
      expect(side_menu_link(taking_care_needs_path)).to have_text('0')
      expect(side_menu_link(done_needs_path)).to have_text('0')
      expect(side_menu_link(not_for_me_needs_path)).to have_text('0')
      expect(side_menu_link(expired_needs_path)).to have_text('0')
    end
  end

  context '1 managed antenne inbox' do
    it 'displays managed antenne received needs pages' do
      visit '/manager/besoins-des-antennes'

      expect(page).to have_current_path(quo_active_manager_needs_path, ignore_query: true)
      expect(page).to have_no_select 'antenne_id'
      expect(page).to have_css('.fr-card__c-container--need', count: 1)
    end
  end

  context '2 managed antennes inbox' do
    let(:managed_antenne_02) { create :antenne }
    let(:expert_antenne_02) { create :expert, antenne: managed_antenne_02 }
    let(:diagnosis_antenne_02) { create :diagnosis_completed }

    let!(:need_taking_care) do
      create(:need, diagnosis: diagnosis_antenne_02, matches: [create(:match, expert: expert_antenne_02, status: :taking_care)])
    end
    let!(:need_not_for_me) do
      create(:need, diagnosis: diagnosis_antenne_02, matches: [create(:match, expert: expert_antenne_02, status: :not_for_me)])
    end

    before do
      user.managed_antennes.push(managed_antenne_02)
    end

    it 'displays all managed antennes received needs pages' do
      visit '/manager/besoins-des-antennes'

      expect(page).to have_select 'antenne_id'
      expect(page).to have_css 'h1', text: managed_antenne_01.name

      expect(page).to have_css('.fr-card__c-container--need', count: 1)

      expect(side_menu_link(quo_active_manager_needs_path)).to have_text('1')
      expect(side_menu_link(taking_care_manager_needs_path)).to have_text('0')
      expect(side_menu_link(done_manager_needs_path)).to have_text('0')
      expect(side_menu_link(not_for_me_manager_needs_path)).to have_text('0')
      expect(side_menu_link(expired_manager_needs_path)).to have_text('0')

      select(managed_antenne_02.name, from: 'antenne_id')
      click_on 'Rechercher'
      expect(page).to have_no_css('.fr-card__c-container--need')
      expect(side_menu_link(quo_active_manager_needs_path(antenne_id: managed_antenne_02.id))).to have_text('0')
      expect(side_menu_link(taking_care_manager_needs_path(antenne_id: managed_antenne_02.id))).to have_text('1')
      expect(side_menu_link(done_manager_needs_path(antenne_id: managed_antenne_02.id))).to have_text('0')
      expect(side_menu_link(not_for_me_manager_needs_path(antenne_id: managed_antenne_02.id))).to have_text('1')
      expect(side_menu_link(expired_manager_needs_path(antenne_id: managed_antenne_02.id))).to have_text('0')
    end
  end

end
