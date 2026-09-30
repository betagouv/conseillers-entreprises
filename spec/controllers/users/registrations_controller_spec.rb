require 'rails_helper'

RSpec.describe Users::RegistrationsController do
  login_user

  describe 'PATCH #update' do
    let(:original_antenne) { current_user.antenne }
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

    it 'does not let a user reassign their own antenne' do
      expect { update_profile }.not_to change { current_user.reload.antenne_id }
      expect(current_user.antenne).to eq(original_antenne)
    end

    it 'keeps legitimate profile fields editable' do
      update_profile

      expect(current_user.reload).to have_attributes(
        full_name: 'Alice Dupont',
        job: 'Conseillère',
        phone_number: '09 87 65 43 21'
      )
    end

    it 'keeps API key rotation scoped to the original institution' do
      original_key = create(:api_key, institution: original_antenne.institution)
      target_key = create(:api_key, institution: target_antenne.institution)
      current_user.user_rights_tech.create!(institution: original_antenne.institution)

      update_profile
      put :reset_api_key

      expect(current_user.reload.antenne).to eq(original_antenne)
      expect(ApiKey.exists?(original_key.id)).to be(false)
      expect(target_key.reload).to be_persisted
      expect(original_antenne.institution.reload.api_key).to be_present
    end
  end
end
