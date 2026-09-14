require 'rails_helper'

RSpec.describe FeedbacksController do
  login_user

  describe 'PUT #create' do
    let(:request) do
      put :create, params: { feedback: { description: "Some Text",
                             feedbackable_id: need.id,
                             feedbackable_type: 'Need',
                             category: 'need' } }
    end
    let(:need) { create :need }

    it 'destroys feedback' do
      request
      expect(Feedback.count).to eq(1)
      expect(response).to have_http_status(:found)
      expect(current_user.reload.last_active_at).to be_within(1.second).of(DateTime.now)
    end
  end

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
