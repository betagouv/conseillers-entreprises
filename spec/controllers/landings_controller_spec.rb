# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingsController, type: :controller do
  describe 'GET #show' do
    before do
      create :landing, slug: 'accueil'
    end

    context 'existing home landing page' do
      it do
        get :home
        expect(response).to be_successful
      end
    end
  end
end
