# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Conseiller::DiagnosesController do
  login_admin

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'POST #create' do
    let(:some_params) { { facility_attributes: { siret: '41816609600069' } } }
    let(:some_params_permitted) { ActionController::Parameters.new(some_params).permit(facility_attributes: [ :siret ]).merge(advisor: advisor) }
    let!(:intermediary_result) { DiagnosisCreation::CreateOrUpdateDiagnosis.new(some_params_permitted) }
    let(:errors) { {} }

    before do
      allow(DiagnosisCreation::CreateOrUpdateDiagnosis).to receive(:new).with(some_params_permitted) { intermediary_result }
      allow(intermediary_result).to receive(:call) { { diagnosis: diagnosis, errors: errors } }
    end

    context 'when creation fails with invalid diagnosis' do
      let(:diagnosis) { build :diagnosis, facility: nil }

      it 'returns an error' do
        post :create, params: { diagnosis: some_params }
        expect(response).to redirect_to new_conseiller_diagnosis_path
      end
    end

    context 'when creation fails with other errors' do
      let(:diagnosis) { build :diagnosis, facility: create(:facility) }
      let(:errors) { { "major_api_error" => { "api-apientreprise-entreprise-base" => "Caramba !" } } }

      it 'returns an error' do
        post :create, params: { diagnosis: some_params }
        expect(response).to redirect_to new_conseiller_diagnosis_path
      end
    end

    context 'when creation succeeds' do
      let(:diagnosis) { create :diagnosis, step: 'contact', solicitation: nil }

      it 'redirects to the diagnosis page' do
        post :create, params: { diagnosis: some_params }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to contact_conseiller_diagnosis_path(Diagnosis.last)
      end
    end

    context 'when from solicitation creation succeeds' do
      let(:diagnosis) { create :diagnosis, solicitation: create(:solicitation) }
      let!(:other_need_subject) { create :subject, id: 59 }

      it 'redirects to the diagnosis page' do
        post :create, params: { diagnosis: some_params }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to matches_conseiller_diagnosis_path(Diagnosis.last)
      end
    end
  end
end
