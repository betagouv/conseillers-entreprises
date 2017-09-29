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

  describe 'GET #step1' do
    it 'returns http success' do
      get :step1
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

    before do
      allow(UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts).to receive(:of_diagnosis).with(diagnosis)
    end

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

  describe 'POST #notify_experts' do
    before do
      allow(ExpertMailersService).to receive(:filter_assistances_experts) { assistance_expert_ids }
      allow(UseCases::CreateSelectedAssistancesExperts).to receive(:perform)
      allow(ExpertMailersService).to receive(:delay) { ExpertMailersService }
      allow(ExpertMailersService).to receive(:send_assistances_email)

      post :notify_experts, params: {
        id: diagnosis.id,
        assistances_experts: assistances_experts
      }
    end
    context 'some experts are selected' do
      let(:assistances_experts) do
        { '12' => '1', '21' => '0', '31' => '0', '42' => '1', '43' => '1', '72' => '1', '90' => '0' }
      end

      let(:assistance_expert_ids) { [12, 42, 43, 72] }

      it('redirects to step 5') { expect(response).to redirect_to step_5_diagnosis_path(diagnosis) }

      it('updates the diagnosis to step 5') { expect(diagnosis.reload.step).to eq 5 }

      it 'has called the right methods' do
        expect(ExpertMailersService).to have_received(:filter_assistances_experts).with(assistances_experts)
        expect(UseCases::CreateSelectedAssistancesExperts).to have_received(:perform).with(
          diagnosis, assistance_expert_ids
        )
      end

      it 'sends emails' do
        expect(ExpertMailersService).to have_received(:send_assistances_email).with(
          advisor: current_user,
          diagnosis: diagnosis,
          assistance_expert_ids: assistance_expert_ids
        )
      end
    end

    context 'no experts are selected' do
      let(:assistances_experts) { nil }
      let(:assistance_expert_ids) { [] }

      it('redirects to step 5') { expect(response).to redirect_to step_5_diagnosis_path(diagnosis) }

      it('updates the diagnosis to step 5') { expect(diagnosis.reload.step).to eq 5 }

      it 'does not call the use case methods' do
        expect(ExpertMailersService).not_to have_received(:filter_assistances_experts)
        expect(UseCases::CreateSelectedAssistancesExperts).not_to have_received(:perform)
      end

      it 'does not send emails' do
        expect(ExpertMailersService).not_to have_received(:send_assistances_email)
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
    before do
      delete :destroy, params: {
        id: diagnosis.id
      }
    end

    it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    it('destroys the diagnosis') { expect(Diagnosis.all.count).to eq 0 }
  end
end
