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

  describe '#notify_other_experts' do
    subject(:mail) { described_class.notify_other_experts(a_match, user).deliver_now }

    let(:a_match) { create :match }
    let(:user) { create :user }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end

  describe '#deduplicated_send_match_notify' do
    def notify_change(new_status)
      previous_status = a_match.status
      a_match.status = new_status
      described_class.deduplicated_send_match_notify(a_match, user, previous_status)
    end

    let(:a_match) { create :match, status: :quo }
    let(:user) { create :user }

    context 'subsequent changes on the same match' do
      before do
        notify_change(:taking_care)
        notify_change(:done)
      end

      it do
        expect(Delayed::Job.count).to eq 1
        previous_status = Delayed::Job.last.payload_object.args.last.to_sym
        expect(previous_status).to eq :quo
      end
    end

    context 'change back to the initial value' do
      before do
        notify_change(:not_for_me)
        notify_change(:quo)
      end

      it do
        expect(Delayed::Job.count).to eq 0
      end
    end
  end
end
