# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::UsersController, type: :controller do
  login_user

  before { current_user.update is_admin: true }

  describe 'send_approval_emails' do
    context 'previously unauthorized user is authorized' do
      let(:user) { create :user, is_approved: false }
      let(:request) { put :update, params: { id: user.id, user: { is_approved: true } } }

      it 'add two jobs in database' do
        expect { request }.to change { Delayed::Job.count }.by(2)
      end
    end

    context 'previously authorized user has his name updated' do
      let(:user) { create :user, is_approved: true, full_name: 'Bob' }
      let(:request) { put :update, params: { id: user.id, user: { full_name: 'not Bob' } } }

      it 'does not add jobs in database' do
        expect { request }.to change { Delayed::Job.count }.by(0)
      end
    end
  end

  describe 'update_params_depending_on_password' do
    before do
      allow(controller).to receive(:scoped_collection).and_return(User)
      allow(User).to receive(:find).with(user.id.to_s).and_return(user)
      allow(user).to receive(:update_without_password)
      allow(user).to receive(:update)
    end

    let(:user) { create :user }

    context 'password entered is blank' do
      before { put :update, params: { id: user.id, user: { password: '' } } }

      it 'updates without password' do
        expect(user).to have_received(:update_without_password)
        expect(user).not_to have_received(:update)
      end
    end

    context 'password entered is present' do
      before { put :update, params: { id: user.id, user: { password: 'new_password' } } }

      it 'updates all attributes' do
        expect(user).not_to have_received(:update_without_password)
        expect(user).to have_received(:update)
      end
    end
  end
end
