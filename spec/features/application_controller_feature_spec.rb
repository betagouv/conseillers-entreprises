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
      password = '1234567'
      user = create :user, password: password, password_confirmation: password

      visit new_user_session_path

      fill_in I18n.t('attributes.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      click_button I18n.t('sign_in')
    end

    it('redirects to diagnoses page') { expect(current_url).to eq diagnoses_url }
  end

  describe 'render_error' do
    login_user

    before do
      ENV['TEST_ERROR_RENDERING'] = 'true'
      allow_any_instance_of(User).to receive(:sent_diagnoses).and_raise(raised_error)
      visit diagnoses_path
    end

    after do
      ENV['TEST_ERROR_RENDERING'] = 'false'
    end

    describe '404 error' do
      let(:raised_error) { ActiveRecord::RecordNotFound }

      it { expect(page.html).to include('Vous n’avez pas accès à cette page !') }
    end

    describe '500 error' do
      let(:raised_error) { ArgumentError }

      it { expect(page.html).to include 'Cette erreur était inattendue…' }
    end
  end
end
