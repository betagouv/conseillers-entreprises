# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#update_match_notify' do
    subject(:mail) { described_class.update_match_notify(match, user, previous_status).deliver_now }

    let(:match) { create :match }
    let(:user) { create :user }
    let(:previous_status) { 'taking_care' }

    it 'has no empty fields' do
      expect(mail.to).not_to be_nil
      expect(mail.from).not_to be_nil
      expect(mail.body).not_to be_nil
      expect(mail.subject).not_to be_nil
    end

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
