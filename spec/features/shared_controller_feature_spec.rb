# frozen_string_literal: true

require 'rails_helper'

describe 'SharedController features' do
  describe 'render_error' do
    login_admin

    # TODO : à mettre à jour
    before do
      ENV['TEST_ERROR_RENDERING'] = 'true'
      # allow_any_instance_of(User).to receive(:received_needs).and_raise(raised_error)
      # # Je comprend pas pourquoi ce test visite une url de diagnoses et si on rien ne passe
    end

    after do
      ENV['TEST_ERROR_RENDERING'] = 'false'
    end

    describe '404 error' do
      it do
        # visit edit_user_path
        expect(page.html).to include I18n.t('shared.errors.404.message')
      end
    end

    describe '500 error' do
      let(:raised_error) { ArgumentError }

      it do
        visit need_path(id: 'wrong_id')
        expect(page.html).to include I18n.t('shared.errors.500.message')
      end
    end
  end
end
