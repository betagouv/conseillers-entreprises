# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::RemindersRegistersController do
  login_admin

  describe '#POST update' do
    create_registers_for_reminders

    before do
      RemindersService.create_reminders_registers
      patch :update, params: { id: expert_input.reload.reminders_registers.last.id }
    end

    it { expect(expert_input.reload.reminders_registers.last.processed).to be true }
  end
end
