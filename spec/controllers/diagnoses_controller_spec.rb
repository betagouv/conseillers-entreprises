# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, visit: visit }
  let(:visit) { create :visit, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #index' do
    it 'returns http success' do
      allow(UseCases::GetDiagnoses).to receive(:for_user).with(current_user)

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #print' do
    it 'returns http success' do
      allow(UseCases::GetQuestionsForPdf).to receive(:perform)

      get :print, format: :pdf

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #step2' do
    subject(:request) { get :step2, params: { id: diagnosis.id } }

    before { allow(UseCases::GetStep2Data).to receive(:for_diagnosis).with(diagnosis) }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to have_http_status(:success) }
    end

    context 'diagnosis step == last' do
      before { diagnosis.update step: Diagnosis::LAST_STEP }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step3' do
    subject(:request) { get :step3, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to have_http_status(:success) }
    end

    context 'diagnosis step == last' do
      before { diagnosis.update step: Diagnosis::LAST_STEP }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step4' do
    subject(:request) { get :step4, params: { id: diagnosis.id } }

    before { allow(UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts).to receive(:of_diagnosis).with(diagnosis) }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to have_http_status(:success) }
    end

    context 'diagnosis step == last' do
      before { diagnosis.update step: Diagnosis::LAST_STEP }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'POST #notify' do
    let(:selected_assistances_experts) do
      {
        'assistances_experts' => { '12' => '1', '90' => '0' },
        'diagnosed_needs' => { '31' => '1', '78' => '0' }
      }
    end

    before do
      allow(UseCases::SaveAndNotifyDiagnosis).to receive(:perform)

      post :notify, params: { id: diagnosis.id, selected_assistances_experts: selected_assistances_experts }
    end

    context 'some experts are selected' do
      it('redirects to step 5') { expect(response).to redirect_to step_5_diagnosis_path(diagnosis) }

      it('updates the diagnosis to step 5') { expect(diagnosis.reload.step).to eq 5 }

      it 'has called the right methods' do
        expect(UseCases::SaveAndNotifyDiagnosis).to have_received(:perform).with(diagnosis,
                                                                                 selected_assistances_experts)
      end
    end
  end

  describe 'GET #step5' do
    subject(:request) { get :step5, params: { id: diagnosis.id } }

    context 'current user can access the diagnosis' do
      it('returns http success') { expect(response).to have_http_status(:success) }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'DELETE #destroy' do
    before { delete :destroy, params: { id: diagnosis.id } }

    it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    it('destroys the diagnosis') { expect(Diagnosis.only_active.count).to eq 0 }
  end
end
