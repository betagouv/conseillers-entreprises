# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
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
