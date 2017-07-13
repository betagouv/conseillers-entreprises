# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationController specific features', type: :feature do
  describe 'authenticate_admin!' do
    login_user

    context 'user is not admin' do
      it do
        visit '/admin'
        expect(page).not_to have_content 'Tableau de bord'
        expect(page).to have_content "Vous n'avez pas accès à cette page."
      end
    end

    context 'user is admin' do
      it do
        current_user.update is_admin: true
        visit '/admin'
        expect(page).to have_content 'Tableau de bord'
      end
    end
  end

  describe 'set_admin_timezone' do
    login_user

    before do
      current_user.update is_admin: true
      user = create :user, created_at: Time.now.utc.beginning_of_day
      visit admin_user_path(user)
    end

    it('displays hour as UTC+2') { expect(page).to have_content '02h00' }
  end

  describe 'after_sign_in_path_for' do
    before do
      password = '1234567'
      user = create :user, password: password, password_confirmation: password

      visit new_user_session_path

      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      click_button I18n.t('sign_in')
    end

    it('redirects to visits page') { expect(current_url).to eq visits_url }
  end

  describe 'render_error' do
    login_user

    before do
      allow(Visit).to receive(:of_advisor).and_raise(raised_error)
      visit visits_path
    end

    describe '404 error' do
      let(:raised_error) { ActiveRecord::RecordNotFound }

      it { expect(page).to have_content "Vous n'avez pas accès à cette page !" }
    end

    describe '500 error' do
      let(:raised_error) { ArgumentError }

      it { expect(page).to have_content 'Cette erreur était inattendue...' }
    end
  end
end
