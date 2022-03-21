# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationController specific features', type: :feature do
  describe 'authenticate_admin!' do
    login_user

    context 'user is not admin' do
      it do
        expect {
          visit '/admin'
        }.to raise_error ActionController::RoutingError
      end
    end

    context 'user is admin' do
      it do
        current_user.user_rights.create(right: 'admin')
        visit '/admin'
        expect(page.html).to include 'Sollicitations'
      end
    end
  end

  describe 'after_sign_in_path_for' do
    let(:password) { 'yX*4Ubo_xPW!u' }

    before do
      visit new_user_session_path
      fill_in I18n.t('attributes.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      click_button I18n.t('sign_in')
    end

    context 'first connexion' do
      let(:user) { create :user, password: password, password_confirmation: password, sign_in_count: 0 }

      it('redirects to tutorial page') { expect(current_url).to eq tutoriels_url }
    end

    context 'already connected' do
      let(:user) { create :user, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to needs quo page') { expect(current_url).to eq quo_needs_url }
    end

    context 'antenne manager connection' do
      let(:user) { create :user, :manager, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to reports page') { expect(current_url).to eq reports_url }
    end

    context 'admin manager connection' do
      let(:user) { create :user, :admin, password: password, password_confirmation: password, sign_in_count: 1 }

      it('redirects to solicitations page') { expect(current_url).to eq solicitations_url }
    end
  end
end
