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
        current_user.update is_admin: true
        visit '/admin'
        expect(page.html).to include 'Sollicitations'
      end
    end
  end

  describe 'after_sign_in_path_for' do
    before do
      password = 'yX*4Ubo_xPW!u'
      user = create :user, password: password, password_confirmation: password

      visit new_user_session_path

      fill_in I18n.t('attributes.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      click_button I18n.t('sign_in')
    end

    it('redirects to diagnoses page') { expect(current_url).to eq diagnoses_url }
  end
end
