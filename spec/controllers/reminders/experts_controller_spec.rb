# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::ExpertsController do
  login_admin

  describe 'relaunch by duration' do
    create_experts_for_reminders

    before { RemindersService.create_reminders_registers }

    describe '#GET many_pending_needs' do
      before { get :many_pending_needs }

      it { expect(assigns(:active_experts)).to match_array([expert_with_many_old_quo_matches]) }
    end

    describe '#GET medium_pending_needs' do
      before { get :medium_pending_needs }

      it { expect(assigns(:active_experts)).to match_array([expert_with_medium_old_quo_matches]) }
    end

    describe '#GET one_pending_need' do
      before { get :one_pending_need }

      it { expect(assigns(:active_experts)).to match_array([expert_with_one_quo_match_1, expert_with_one_old_quo_match]) }
    end
  end

  describe 'input and output' do
    create_registers_for_reminders

    before do
      RemindersService.create_reminders_registers
      expert_input_processed.reminders_registers.last.update(processed: true )
    end

    describe '#GET inputs' do
      before { get :inputs }

      it { expect(assigns(:active_experts)).to match_array([expert_input]) }
    end

    describe '#GET outputs' do
      before { get :outputs }

      it { expect(assigns(:active_experts)).to match_array([expert_output]) }
    end

    describe '#POST process_register' do
      before { post :process_register, params: { id: expert_input.id } }

      it { expect(expert_input.reload.reminders_registers.last.processed).to be true }
    end
  end
end
