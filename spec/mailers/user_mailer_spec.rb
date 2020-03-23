# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#notify_match_status' do
    subject(:mail) { described_class.notify_match_status(a_match, previous_status).deliver_now }

    let(:a_match) { create :match }
    let(:previous_status) { 'taking_care' }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
