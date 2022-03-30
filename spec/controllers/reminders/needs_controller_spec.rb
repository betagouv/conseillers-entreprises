# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::NeedsController, type: :controller do
  login_admin

  describe 'POST #send_abandoned_email' do
    let!(:need) { create :need }

    before { post :send_abandoned_email, params: { id: need.id } }

    it 'send email and set abandoned_email_sent' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(need.reload.abandoned_email_sent).to be true
    end
  end
end
