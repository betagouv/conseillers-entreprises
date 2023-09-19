# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController do
  login_admin

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'POST #create' do
    let(:some_params) { { facility_attributes: { siret: '12345678901234' } } }

    before do
      allow(DiagnosisCreation).to receive(:create_diagnosis) { result }
    end

    context 'when creation fails' do
      let(:result) { build :diagnosis, facility: nil }

      it 'returns an error' do
        post :create, params: { diagnosis: some_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when creation succeeds' do
      let(:result) { create :diagnosis, step: 'contact', solicitation: nil }

      it 'redirects to the diagnosis page' do
        post :create, params: { diagnosis: some_params }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to contact_diagnosis_path(Diagnosis.last)
      end
    end

    context 'when from solicitation creation succeeds' do
      let(:result) { create :diagnosis, solicitation: create(:solicitation) }
      let!(:other_need_subject) { create :subject, id: 59 }

      it 'redirects to the diagnosis page' do
        post :create, params: { diagnosis: some_params }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to matches_diagnosis_path(Diagnosis.last)
      end
    end
  end
end
