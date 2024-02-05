# frozen_string_literal: true

require 'rails_helper'

describe 'experts' do
  describe 'expert update' do
    let(:other_user) { create :user }
    let(:team) { create :expert, users: [other_user, current_user] }

    login_user

    before do
      visit edit_expert_path(team.id)

      fill_in id: 'expert_job', with: 'Doer of things'
      fill_in id: 'expert_phone_number', with: '0987654321'

      click_on 'Mettre à jour'
    end

    it 'updates the expert info' do
      team.reload
      expect(team.reload.job).to eq 'Doer Of Things'
      expect(team.reload.phone_number).to eq '09 87 65 43 21'
    end
  end
end
