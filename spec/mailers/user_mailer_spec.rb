# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#update_match_notify' do
    subject(:mail) { described_class.update_match_notify(a_match, user, previous_status).deliver_now }

    let(:a_match) { create :match }
    let(:user) { create :user }
    let(:previous_status) { 'taking_care' }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
