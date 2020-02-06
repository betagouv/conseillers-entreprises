# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingsController, type: :controller do
  describe 'GET #show' do
    before do
      create :landing, slug: 'existing_landing'
    end

    context 'existing landing page' do
      it do
        get :show, params: { slug: 'existing_landing' }
        expect(response).to be_successful
      end
    end

    context 'unknown landing page' do
      it do
        get :show, params: { slug: 'unknown_landing' }
        expect(response).to redirect_to root_path
      end
    end
  end
end
