# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe BadgesController do
  login_admin

  describe 'GET #solicitations' do
    let(:solicitations_badge) { create(:badge, category: :solicitations) }
    let(:needs_badge) { create(:badge, category: :needs) }

    let(:request) { post :solicitations }

    it 'displays only badges for solicitations' do
      request
      expect(assigns(:badges)).to contain_exactly(solicitations_badge)
    end
  end

  describe 'GET #needs' do
    let(:solicitations_badge) { create(:badge, category: :solicitations) }
    let(:needs_badge) { create(:badge, category: :needs) }

    let(:request) { post :needs }

    it 'displays only badges for needs' do
      request
      expect(assigns(:badges)).to contain_exactly(needs_badge)
    end
  end

  describe 'POST #create' do
    let(:request) { post :create, params: { badge: { title: 'test badge', color: '#00000', category: :solicitations } } }

    it 'creates badges' do
      request
      expect(Badge.count).to eq(1)
      expect(Badge.first.title).to eq('test badge')
      expect(Badge.first.color).to eq('#00000')
      expect(Badge.first.category).to eq('solicitations')
    end
  end

  describe 'PUT #update' do
    let(:badge) { create(:badge, category: :solicitations) }
    let(:request) { put :update, params: { id: badge.id, badge: { title: 'update badge', color: '#fffff', category: :needs } } }

    it 'updates badge' do
      request
      expect(badge.reload.title).to eq('update badge')
      expect(badge.reload.color).to eq('#fffff')
      expect(badge.reload.category).to eq('needs')
    end
  end

  describe 'DELETE #destroy' do
    let(:badge) { create(:badge) }
    let(:request) { delete :destroy, params: { id: badge.id } }

    it 'destroys badge' do
      request
      expect(Badge.count).to eq(0)
    end
  end
end
