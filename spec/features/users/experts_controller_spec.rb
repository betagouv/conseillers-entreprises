# frozen_string_literal: true

require 'rails_helper'

describe 'experts', type: :feature do
  describe 'expert update' do
    let(:other_user) { create :user }
    let(:team) { create :expert, users: [other_user, current_user] }

    login_user

    before do
      visit edit_expert_path(team.id)

      fill_in id: 'expert_role', with: 'Doer of things'
      fill_in id: 'expert_phone_number', with: '0987654321'

      click_button 'Mettre à jour'
    end

    it 'updates the expert info' do
      team.reload
      expect(team.reload.role).to eq 'Doer of things'
      expect(team.reload.phone_number).to eq '0987654321'
    end
  end
end
