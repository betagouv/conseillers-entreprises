# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe ExpertMailer do
  describe '#notify_company_needs' do
    subject(:mail) { described_class.notify_company_needs(expert, diagnosis).deliver_now }

    let(:expert) { create :expert }
    let(:user) { create :user }
    let(:subject1) { create :subject }
    let(:diagnosis) { create :diagnosis, advisor: user, visitee: create(:contact, :with_email) }
    let(:subjects_with_needs_description) { [{ subject: subject1, need_description: 'Help this company' }] }

    let(:params_hash) do
      {
        visit_date: diagnosis.happened_on,
        diagnosis_id: diagnosis.id,
        company_name: diagnosis.company.name,
        company_contact: diagnosis.visitee,
        subjects_with_needs_description: subjects_with_needs_description,
        advisor: user
      }
    end

    describe 'email behavior' do
      it_behaves_like 'an email'

      it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
    end

    describe 'password instructions reminder' do
      let(:expert) { create :expert, users: expert_members }

      context 'solo expert, never use' do
        let(:expert_members) { [build(:user, invitation_accepted_at: nil)] }

        it do
          expect_any_instance_of(User).to receive(:send_reset_password_instructions).once

          mail
        end
      end

      context 'solo expert, used account' do
        let(:expert_members) { [build(:user, invitation_accepted_at: DateTime.now)] }

        it do
          expect_any_instance_of(User).not_to receive(:send_reset_password_instructions)

          mail
        end
      end

      context 'expert with several users' do
        let(:user1) { build :user, invitation_sent_at: nil, encrypted_password: '' }
        let(:user2) { build :user, invitation_sent_at: nil, encrypted_password: '' }
        let(:expert_members) { [user1, user2] }

        it do
          count = 0
          allow_any_instance_of(User).to receive(:send_reset_password_instructions) do |user|
            expect(expert_members).to include user
            count += 1
          end

          mail
          expect(count).to eq(2)
        end
      end

      context 'expert with deleted user ' do
        let(:user1) { build :user, invitation_sent_at: nil, encrypted_password: '' }
        let(:user2) { build :user, invitation_sent_at: nil, encrypted_password: '', deleted_at: Time.zone.now }
        let(:expert_members) { [user1, user2] }

        it do
          count = 0
          allow_any_instance_of(User).to receive(:send_reset_password_instructions) do |user|
            expect(user2).not_to eq(user)
            count += 1
          end

          mail
          expect(count).to eq(1)
        end
      end
    end
  end

  describe '#remind_involvement' do
    subject(:mail) do
      described_class.remind_involvement(expert).deliver_now
    end

    let(:expert) { create :expert }

    before do
      create :match, expert: expert
    end

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
