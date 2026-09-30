require 'rails_helper'

RSpec.describe Users::InvitationsController do
  setup_devise_mapping_for_controllers
  mock_landing_themes

  describe 'PUT #update' do
    let(:user) { create :user, antenne: original_antenne, full_name: "John Doe", job: "Expert", phone_number: "0123456789" }
    let(:original_antenne) { create(:antenne) }
    let(:target_antenne) { create(:antenne) }

    before { user.invite! }

    subject(:accept_invite) do
      put :update, params: {
        user: {
          invitation_token: user.raw_invitation_token,
          antenne_id: target_antenne.id,
          full_name: 'Alice Dupont',
          job: 'Conseillère',
          phone_number: '0987654321',
          password: 'aaQQwwXXssZZ22##',
        }
      }
    end

    it 'allows invited user to edit values' do
      accept_invite

      expect(user.reload).to have_attributes(full_name: 'Alice Dupont', job: 'Conseillère', phone_number: '09 87 65 43 21')
    end

    it 'does not let a user reassign their own antenne' do
      accept_invite

      expect(user.reload.antenne).to eq(original_antenne)
    end
  end
end
