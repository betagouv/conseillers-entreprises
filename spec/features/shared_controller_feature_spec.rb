# frozen_string_literal: true

require 'rails_helper'

describe 'SharedController features', type: :feature do
  describe 'render_error' do
    login_admin

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

      it { expect(page.html).to include('Cette page n’existe pas, ou vous n’y avez pas accès.') }
    end

    describe '500 error' do
      let(:raised_error) { ArgumentError }

      it { expect(page.html).to include 'Cette erreur était inattendue…' }
    end
  end
end
