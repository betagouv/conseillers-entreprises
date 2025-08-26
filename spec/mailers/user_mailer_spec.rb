# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#invite_to_demo' do
    let!(:national_referent) { create :user, :national_referent }

    subject(:mail) { described_class.with(user: user).invite_to_demo.deliver_now }

    context 'when user has subjects' do
      let(:user) { create :user, :with_expert_subjects }

      it_behaves_like 'an email'

      it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
    end

    context 'when user has no subjects' do
      let(:user) { create :user }

      let(:mail) { subject }

      it { expect(mail).to be_nil }
    end
  end
end
