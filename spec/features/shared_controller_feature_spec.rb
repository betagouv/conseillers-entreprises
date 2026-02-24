require 'rails_helper'

describe 'SharedController features' do
  describe 'render_error' do
    before do
      ENV['TEST_ERROR_RENDERING'] = 'true'
    end

    after do
      ENV['TEST_ERROR_RENDERING'] = 'false'
    end

    context 'on html pages' do
      login_admin

      before do
        create_home_landing
        allow_any_instance_of(User).to receive(:received_needs).and_raise(raised_error)
        visit quo_active_needs_path
      end

      describe '404 error' do
        let(:raised_error) { ActiveRecord::RecordNotFound }

        it { expect(page.html).to include(I18n.t('shared.errors.404.message')) }
      end

      describe '500 error' do
        let(:raised_error) { ArgumentError }

        it { expect(page.html).to include I18n.t('shared.errors.500.message') }
      end
    end

    context 'on resources' do
      before { visit '/nonexistant.png' }

      it do
        expect(page.status_code).to eq 404
        expect(page.body).to be_empty
      end
    end
  end
end
