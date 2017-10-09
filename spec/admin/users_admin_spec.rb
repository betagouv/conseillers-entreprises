# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::UsersController, type: :controller do
  login_user

  before { current_user.update! is_admin: true }

  describe 'PUT update' do
    context 'previously unauthorized user is authorized' do
      let(:user) { create :user, is_approved: false }
      let(:request) { put :update, params: { id: user.id, user: { is_approved: true } } }

      it 'add two jobs in database' do
        expect { request }.to change { Delayed::Job.count }.by(2)
      end
    end

    context 'previously authorized user has his name updated' do
      let(:user) { create :user, is_approved: true, first_name: 'Bob' }
      let(:request) { put :update, params: { id: user.id, user: { first_name: 'not Bob' } } }


      it 'does not add jobs in database' do
        expect { request }.to change { Delayed::Job.count }.by(0)
      end
    end
  end
end