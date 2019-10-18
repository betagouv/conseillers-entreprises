# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::UsersController, type: :controller do
  login_user

  before { current_user.update is_admin: true }

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
