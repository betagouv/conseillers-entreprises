# frozen_string_literal: true

require 'rails_helper'

describe 'the signin process' do
  let!(:user) { create :user, :with_expert, email: 'user@example.com', password: 'yX*4Ubo_xPW!u', invitation_token: invitation_token }

  before do
    create_home_landing
    visit new_user_session_path
    within('#new_user') do
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Mot de passe', with: 'yX*4Ubo_xPW!u'
    end
  end

  context 'regular sign in' do
    let(:invitation_token) { nil }

    context 'active user' do
      it do
        within '.new_user' do
          click_on 'Accès conseillers', class: 'fr-btn'
        end

        expect(page.html).to include 'Mes besoins'
      end
    end
  end

  context 'sign in while invited' do
    let(:invitation_token) { 'aaabbbccc111222333' }

    it 'doesnt connect if invitation token present' do
      within '.new_user' do
        click_on 'Accès conseillers', class: 'fr-btn'
      end

      expect(page.html).not_to include 'Mes besoins'
      expect(current_url).to eq new_user_session_url
    end
  end
end
