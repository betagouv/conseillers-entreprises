# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#notify_match_status' do
    subject(:mail) { described_class.notify_match_status(a_match, previous_status).deliver_now }

    let(:a_match) { create :match }
    let(:previous_status) { 'taking_care' }

    describe 'when the recipient is not deleted' do
      it_behaves_like 'an email'

      it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
    end

    describe 'when the recipient is deleted' do
      before { a_match.advisor.soft_delete }

      let(:mail) { subject }

      it { expect(mail).to be_nil }
    end

    describe 'when the recipient is admin' do
      before { a_match.advisor.update(role_admin: true) }

      let(:mail) { subject }

      it { expect(mail).to be_nil }
    end
  end

  describe '#match_feedback' do
    subject(:mail) { described_class.match_feedback(feedback, user).deliver_now }

    let(:feedback) { create :feedback, :for_need }
    let(:advisor) { create :user }
    let(:user) { create :user }

    describe 'when the recipient is not deleted' do
      it_behaves_like 'an email'

      it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
    end

    describe 'when the recipient is deleted' do
      before { user.soft_delete }

      let(:mail) { subject }

      it { expect(mail).to be_nil }
    end
  end
end
