# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #about' do
    it 'returns http success' do
      get :about
      expect(response).to be_successful
    end
  end

  describe 'GET #cgu' do
    it 'returns http success' do
      get :cgu
      expect(response).to be_successful
    end
  end

  describe 'GET #contact' do
    it 'returns http success' do
      get :contact
      expect(response).to be_successful
    end
  end
end
