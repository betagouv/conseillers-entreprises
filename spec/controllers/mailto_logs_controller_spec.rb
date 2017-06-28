# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailtoLogsController, type: :controller do
  login_user

  describe 'POST #create' do
    before do
      visit = create :visit
      post :create,
           params: {
             mailto_log: { question_id: question_id, visit_id: visit.id, assistance_id: assistance_id }
           },
           format: :js
    end

    context 'with question' do
      let(:question) { create :question }
      let(:question_id) { question.id }

      context 'with assistance' do
        let(:assistance) { create :assistance }
        let(:assistance_id) { assistance.id }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
          expect(MailtoLog.last.question).to eq question
          expect(MailtoLog.last.assistance).to eq assistance
        end
      end

      context 'without assistance' do
        let(:assistance_id) { nil }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
          expect(MailtoLog.last.question).to eq question
          expect(MailtoLog.last.assistance).to be_nil
        end
      end
    end

    context 'without question' do
      let(:question_id) { nil }
      let(:assistance_id) { nil }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
        expect(MailtoLog.last).to be_nil
      end
    end
  end
end
