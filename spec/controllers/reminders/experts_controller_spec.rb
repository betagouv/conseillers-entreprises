# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::ExpertsController do
  login_admin

  describe 'relaunch by duration' do
    create_experts_for_reminders

    before { RemindersService.create_reminders_registers }

    describe '#GET many_pending_needs' do
      subject(:request) { get :many_pending_needs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_many_old_quo_matches])
      end
    end

    describe '#GET medium_pending_needs' do
      subject(:request) { get :medium_pending_needs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_medium_old_quo_matches])
      end
    end

    describe '#GET one_pending_need' do
      subject(:request) { get :one_pending_need }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_with_one_quo_match_1, expert_with_one_old_quo_match])
      end
    end
  end

  describe 'input and output' do
    create_registers_for_reminders

    before { RemindersService.create_reminders_registers }

    describe '#GET inputs' do
      subject(:request) { get :inputs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_input])
      end
    end

    describe '#GET outputs' do
      subject(:request) { get :outputs }

      it do
        request
        expect(assigns(:active_experts)).to match_array([expert_output])
      end
    end

    describe '#POST process_register' do
      before { post :process_register, params: { id: expert_input.id } }

      it { expect(expert_input.reload.reminders_registers.last.processed).to be true }
    end
  end
end
