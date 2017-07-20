# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DiagnosedNeedsController, type: :controller do
  login_user

  let(:visit) { create :visit, advisor: current_user }
  let(:diagnosis) { create :diagnosis, visit: visit, content: Faker::Lorem.paragraph }
  let(:question1) { create :question }
  let(:question2) { create :question }

  describe 'POST #create' do
    describe 'in case of success' do
      let(:diagnosed_needs_array) do
        [
          { question_id: question1.id, content: Faker::Lorem.paragraph },
          { question_id: question2.id, content: Faker::Lorem.paragraph }
        ]
      end

      before do
        post :create, format: :json, params: { diagnosis_id: diagnosis.id, diagnosed_needs: diagnosed_needs_array }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:created)
      end

      it 'creates two diagnosed needs' do
        expect(DiagnosedNeed.all.count).to eq(2)
        expect(DiagnosedNeed.first.question_id).to eq(diagnosed_needs_array.first[:question_id])
        expect(DiagnosedNeed.last.question_id).to eq(diagnosed_needs_array.last[:question_id])
        expect(DiagnosedNeed.first.content).to eq(diagnosed_needs_array.first[:content])
        expect(DiagnosedNeed.last.content).to eq(diagnosed_needs_array.last[:content])
      end
    end

    describe 'in case of error' do
      let(:diagnosed_needs_array) do
        [
          { question_id: question1.id, content: Faker::Lorem.paragraph },
          { question_id: "lol_id", content: Faker::Lorem.paragraph }
        ]
      end

      before do
        post :create, format: :json, params: { diagnosis_id: diagnosis.id, diagnosed_needs: diagnosed_needs_array }
      end

      it 'returns http bad_request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create any diagnosed needs' do
        expect(DiagnosedNeed.all.count).to eq(0)
      end
    end
  end
end
