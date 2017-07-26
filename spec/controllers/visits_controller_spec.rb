# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  login_user

  describe 'GET #show' do
    it 'returns http success' do
      visit = create :visit, advisor: current_user
      allow(UseCases::SearchFacility).to receive(:with_siret).with(visit.facility.siret)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit_visitee' do
    it 'returns http success' do
      visit = create :visit, advisor: current_user
      get :edit_visitee, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update_visitee' do
    subject do
      patch :update_visitee,
            params: {
              id: visit.id,
              visit: { visitee_attributes: visitee_attributes },
              diagnosis_id: diagnosis_id
            }
    end

    let(:visit) { create :visit, advisor: current_user }
    let(:contact) { build :contact, :with_email, :with_phone_number }
    let(:diagnosis_id) { nil }

    context 'when save worked' do
      let(:visitee_attributes) do
        {
          full_name: contact.full_name,
          email: contact.email,
          role: contact.role,
          phone_number: contact.phone_number
        }
      end

      context 'there is no diagnosis_id' do
        it 'redirects to the visit list' do
          is_expected.to redirect_to visit_path(visit)
        end
      end

      context 'there is a diagnosis_id' do
        let(:diagnosis) { create :diagnosis, visit: visit }
        let(:diagnosis_id) { diagnosis.id }

        it 'redirects to the diagnosis page' do
          is_expected.to redirect_to visit_diagnosis_path(visit_id: visit.id, id: diagnosis_id)
        end
      end
    end

    context 'saved failed' do
      let(:visitee_attributes) { { full_name: contact.full_name } }

      it 'does not redirect' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
