# frozen_string_literal: true

require 'rails_helper'
RSpec.describe RemindersActionsController do
  login_admin

  describe 'POST #poke' do
    let(:need) { create :need_with_matches }

    it do
      post :poke, params: { id: need.id }
      expect(need.reminders_actions.pluck(:category)).to match_array ['poke']
      expect(response).to redirect_to poke_reminders_needs_path
    end
  end

  describe 'POST #recall' do
    let(:need) { create :need_with_matches }

    it do
      post :recall, params: { id: need.id }
      expect(need.reminders_actions.pluck(:category)).to match_array ['recall']
      expect(response).to redirect_to recall_reminders_needs_path
    end
  end

  describe 'POST #last_chance' do
    let(:need) { create :need_with_matches }

    it do
      post :last_chance, params: { id: need.id }
      expect(need.reminders_actions.pluck(:category)).to match_array ['last_chance']
      expect(response).to redirect_to last_chance_reminders_needs_path
    end
  end

  describe 'POST #archive' do
    let(:need) { create :need_with_matches }

    it do
      post :archive, params: { id: need.id }
      expect(need.reload.archived_at).not_to be_nil
      expect(response).to redirect_to not_for_me_reminders_needs_path
    end
  end
end
