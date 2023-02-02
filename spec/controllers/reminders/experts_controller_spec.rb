# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::ExpertsController do
  login_admin

  describe 'relaunch tabs' do
    create_experts_for_reminders

    before { RemindersService.create_reminders_registers }

    describe '#GET many_pending_needs' do
      subject(:request) { get :many_pending_needs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_many_old_quo_needs])
      end
    end

    describe '#GET medium_pending_needs' do
      subject(:request) { get :medium_pending_needs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_medium_old_quo_needs])
      end
    end

    describe '#GET one_pending_need' do
      subject(:request) { get :one_pending_need }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_one_quo_need, expert_with_one_old_quo_need])
      end
    end
  end
end
