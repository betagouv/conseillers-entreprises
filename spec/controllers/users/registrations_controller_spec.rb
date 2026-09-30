require 'rails_helper'

RSpec.describe Users::RegistrationsController do
  login_user
  mock_landing_themes

  describe 'PATCH #update' do
    let(:current_user) { create :user, antenne: original_antenne, full_name: "John Doe", job: "Expert", phone_number: "0123456789" }
    let(:original_antenne) { create(:antenne) }
    let(:target_antenne) { create(:antenne) }

    subject(:update_profile) do
      patch :update, params: {
        user: {
          antenne_id: target_antenne.id,
          full_name: 'Alice Dupont',
          job: 'Conseillère',
          phone_number: '0987654321'
        }
      }
    end

    it 'allows user to edit values' do
      update_profile

      expect(current_user.reload).to have_attributes(full_name: 'Alice Dupont', job: 'Conseillère', phone_number: '09 87 65 43 21')
    end

    it 'does not let a user reassign their own antenne' do
      update_profile

      expect(current_user.reload.antenne).to eq(original_antenne)
    end
  end
end
