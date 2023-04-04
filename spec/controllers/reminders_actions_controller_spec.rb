# frozen_string_literal: true

require 'rails_helper'
RSpec.describe RemindersActionsController do
  login_admin

  describe 'POST #poke' do
    let(:need) { create :need_with_matches }

    it do
      post :create, params: { need_id: need.id, category: 'poke' }
      expect(need.reminders_actions.pluck(:category)).to match_array ['poke']
      expect(response).to redirect_to poke_reminders_needs_path
    end
  end

  describe 'POST #last_chance' do
    let(:need) { create :need_with_matches }

    it do
      request.headers.merge!({ referer: last_chance_reminders_needs_path })
      post :create, params: { need_id: need.id, category: 'last_chance' }
      expect(need.reminders_actions.pluck(:category)).to match_array ['last_chance']
      expect(response).to redirect_to last_chance_reminders_needs_path
    end
  end

  describe 'POST #abandon' do
    let(:need) { create :need_with_matches }

    it do
      request.headers.merge!({ referer: abandon_reminders_needs_path })
      post :create, params: { need_id: need.id, category: 'abandon' }
      expect(need.reminders_actions.pluck(:category)).to match_array ['abandon']
      expect(response).to redirect_to abandon_reminders_needs_path
    end
  end
end
