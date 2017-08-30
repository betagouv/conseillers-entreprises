# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DiagnosedNeedsController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, content: Faker::Lorem.paragraph }
  let(:question1) { create :question }

  describe 'POST #bulk' do
    let!(:diagnosed_need1) { create :diagnosed_need, diagnosis: diagnosis, content: 'Not random content' }
    let!(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis }
    let!(:diagnosed_need3) { create :diagnosed_need, diagnosis: diagnosis }

    describe 'in case of success' do
      let(:bulk_params) do
        {
          create: [{ question_id: question1.id, question_label: question1.label, content: 'Random content' }],
          update: [{ id: diagnosed_need1.id, content: 'New content' }],
          delete: [{ id: diagnosed_need2.id }, { id: diagnosed_need3.id }]
        }
      end

      before do
        post :bulk, format: :json, params: { diagnosis_id: diagnosis.id, bulk_params: bulk_params }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates one new diagnosed need' do
        expect(DiagnosedNeed.all.count).to eq(2)
        expect(DiagnosedNeed.last.question_id).to eq(question1.id)
        expect(DiagnosedNeed.last.content).to eq('Random content')
        expect(DiagnosedNeed.last.question_label).to eq(question1.label)
      end

      it 'updates the flagged toUpdate diagnosed need' do
        expect(diagnosed_need1.reload.content).to eq('New content')
      end

      it 'deletes the flagged toDelete diagnosed need' do
        expect(DiagnosedNeed.where(id: diagnosed_need2.id)).not_to exist
        expect(DiagnosedNeed.where(id: diagnosed_need3.id)).not_to exist
      end
    end

    describe 'in case of error' do
      let(:bulk_params) do
        {
          create: [{ question_id: question1.id, question_label: question1.label, content: 'Random content' }],
          update: [{ id: nil, content: 'New content' }],
          delete: [{ id: diagnosed_need2.id }, { id: diagnosed_need3.id }]
        }
      end

      before do
        post :bulk, format: :json, params: { diagnosis_id: diagnosis.id, bulk_params: bulk_params }
      end

      it 'returns http bad_request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not change anything' do
        expect(DiagnosedNeed.all.count).to eq(3)
        expect(DiagnosedNeed.where(id: diagnosed_need2.id)).to exist
        expect(DiagnosedNeed.where(id: diagnosed_need3.id)).to exist
        expect(diagnosed_need1.reload.content).to eq 'Not random content'
      end
    end
  end
end
