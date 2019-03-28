# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to be_successful
    end
  end

  describe 'GET #step2' do
    subject(:request) { get :step2, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step3' do
    subject(:request) { get :step3, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step4' do
    subject(:request) { get :step4, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'POST #selection' do
    let(:matches) do
      {
        'experts_skills' => { '12' => '1', '90' => '0' },
        'diagnosed_needs' => { '31' => '1', '78' => '0' }
      }
    end

    before do
      allow(UseCases::SaveAndNotifyDiagnosis).to receive(:perform)

      post :selection, params: { id: diagnosis.id, matches: matches }
    end

    context 'some experts are selected' do
      it('redirects to the besoins page') { expect(response).to redirect_to besoin_path(diagnosis) }

      it('updates the diagnosis to step 5') { expect(diagnosis.reload.step).to eq 5 }

      it 'has called the right methods' do
        expect(UseCases::SaveAndNotifyDiagnosis).to have_received(:perform).with(diagnosis,
          matches)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { delete :destroy, params: { id: diagnosis.id } }

    it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    it('destroys the diagnosis') { expect(Diagnosis.archived(false).count).to eq 0 }
  end
end
