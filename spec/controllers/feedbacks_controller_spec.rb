require 'rails_helper'

RSpec.describe FeedbacksController do
  login_user

  describe 'DELETE #destroy' do
    context 'when feedback exists' do
      let(:request) { delete :destroy, params: { id: feedback.id } }
      let(:feedback) { create(:feedback, :for_need, user: current_user) }

      it 'destroys feedback' do
        request
        expect(Feedback.count).to eq(0)
        expect(response).to have_http_status(:found)
      end
    end

    context 'when feedback does not exist' do
      let(:request) { delete :destroy, params: { id: 3 } }
      let(:feedback) { nil }

      it 'return nothing' do
        request
        expect(Feedback.count).to eq(0)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
