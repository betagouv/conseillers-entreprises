# frozen_string_literal: true

require 'rails_helper'

describe ExpertMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_assistances_email' do
    subject(:send_assistances_email) do
      described_class.send_assistances_email(
        advisor: user, diagnosis: diagnosis, assistance_expert_ids: assistance_expert_ids
      )
    end

    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee }
    let(:diagnosis) { create :diagnosis, visit: visit }
    let(:question) { create :question }
    let(:assistance) { create :assistance, question: question }

    let(:assistances_experts) { create_list :assistance_expert, 3, assistance: assistance }
    let(:assistance_expert_ids) { [assistances_experts.first.id, assistances_experts.last.id] }

    before { create :diagnosed_need, question: question, diagnosis: diagnosis }

    it { expect { send_assistances_email }.to change { ActionMailer::Base.deliveries.count }.by 2 }
  end

  describe 'send_relay_assistances_email' do
    subject(:send_relay_assistances_email) do
      described_class.send_relay_assistances_email(
        relay: relay,
        diagnosed_need_ids: diagnosed_needs.map(&:id),
        advisor: advisor,
        diagnosis: diagnosis
      )
    end

    let(:advisor) { create :user }
    let(:relay) { create :relay }
    let(:visit) { create :visit, :with_visitee }
    let(:diagnosis) { create :diagnosis, visit: visit }
    let(:diagnosed_needs) { create_list :diagnosed_need, 2 }

    it { expect { send_relay_assistances_email }.to change { ActionMailer::Base.deliveries.count }.by 1 }
  end

  describe 'retrieve_assistances_experts' do
    subject(:retrieve_assistances_experts) do
      described_class.send(:retrieve_assistances_experts, assistance_expert_ids)
    end

    let(:assistances_experts) { create_list :assistance_expert, 3 }
    let(:assistance_expert_ids) { assistances_experts.map(&:id) }

    it { is_expected.to match_array assistances_experts }
  end

  describe 'questions_grouped_by_experts' do
    subject(:questions_grouped_by_experts) do
      described_class.send(:questions_grouped_by_experts, assistances_experts, diagnosis)
    end

    let(:diagnosis) { create :diagnosis }

    context 'when there is no assistance expert' do
      let(:assistances_experts) { [] }

      it { is_expected.to eq [] }
    end

    context 'when there is one assistance expert' do
      let(:expert) { create :expert }
      let(:question) { create :question }
      let(:assistance) { create :assistance, question: question }
      let(:assistance_expert) { create :assistance_expert, expert: expert, assistance: assistance }
      let(:assistances_experts) { [assistance_expert] }
      let!(:diagnosed_need) { create :diagnosed_need, question: question, diagnosis: diagnosis }

      let(:expected_array) { [{ question: question, need_description: diagnosed_need.content }] }

      it { is_expected.to eq [{ expert: expert, questions_with_needs_description: expected_array }] }
    end

    context 'when there are several assistances experts linked to different questions' do
      let(:expert) { create :expert }
      let(:assistances_experts) { [ae1, ae2] }

      let(:question1) { create :question }
      let!(:diagnosed_need1) { create :diagnosed_need, question: question1, diagnosis: diagnosis }
      let(:assistance1) { create :assistance, question: question1 }
      let(:ae1) { create :assistance_expert, expert: expert, assistance: assistance1 }

      let(:question2) { create :question }
      let!(:diagnosed_need2) { create :diagnosed_need, question: question2, diagnosis: diagnosis }
      let(:assistance2) { create :assistance, question: question2 }
      let(:ae2) { create :assistance_expert, expert: expert, assistance: assistance2 }

      let(:expected_array) do
        [
          { question: question1, need_description: diagnosed_need1.content },
          { question: question2, need_description: diagnosed_need2.content }
        ]
      end

      it { is_expected.to eq [{ expert: expert, questions_with_needs_description: expected_array }] }
    end

    xcontext 'when there are several assistances experts linked to the same question' do
      let(:expert) { create :expert }
      let(:question) { create :question }
      let!(:diagnosed_need) { create :diagnosed_need, question: question, diagnosis: diagnosis }

      let(:assistance1) { create :assistance, question: question }
      let(:ae1) { create :assistance_expert, expert: expert, assistance: assistance1 }

      let(:assistance2) { create :assistance, question: question }
      let(:ae2) { create :assistance_expert, expert: expert, assistance: assistance2 }

      let(:assistances_experts) { [ae1, ae2] }

      let(:expected_array) { [{ question: question, need_description: diagnosed_need.content }] }

      it { is_expected.to eq [{ expert: expert, questions_with_needs_description: expected_array }] }
    end
  end

  describe 'notify_expert' do
    subject(:notify_expert) do
      described_class.send(:notify_expert, expert_hash, user, diagnosis)
    end

    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee }
    let(:diagnosis) { create :diagnosis, visit: visit }

    let(:expert) { create :expert }
    let(:expert_hash) { { expert: expert, questions_with_needs_description: questions_with_needs_description } }
    let(:questions_with_needs_description) { [{ question: question, need_description: 'Help this company' }] }
    let(:question) { create :question }

    let(:email_params) do
      {
        advisor: user,
        diagnosis_id: diagnosis.id,
        visit_date: diagnosis.visit.happened_on_localized,
        company_name: diagnosis.visit.company_name,
        company_contact: diagnosis.visit.visitee,
        questions_with_needs_description: questions_with_needs_description
      }
    end

    it do
      allow(ExpertMailer).to receive(:notify_company_needs).and_call_original

      notify_expert

      expect(ExpertMailer).to have_received(:notify_company_needs).with(expert, email_params)
    end
  end
end
