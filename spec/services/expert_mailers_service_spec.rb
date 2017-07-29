# frozen_string_literal: true

require 'rails_helper'

describe ExpertMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_assistances_email' do
    subject(:send_assistances_email) do
      described_class.send_assistances_email(
        advisor: user, diagnosis: diagnosis, assistances_experts_hash: assistances_experts_hash
      )
    end

    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee }
    let(:diagnosis) { create :diagnosis, visit: visit }

    let(:assistances_experts) { create_list :assistance_expert, 3 }
    let(:assistances_experts_hash) do
      {
        assistances_experts[0].id.to_s => '1',
        assistances_experts[1].id.to_s => '0',
        assistances_experts[2].id.to_s => '1'
      }
    end

    it { expect { send_assistances_email }.to change { ActionMailer::Base.deliveries.count }.by(2) }
  end

  describe 'filter_assistances_experts' do
    subject(:filter_assistances_experts) do
      described_class.filter_assistances_experts(assistances_experts_hash)
    end

    let(:assistances_experts_hash) do
      { '12' => '1', '42' => '1', '43' => '1', '72' => '1', '21' => '0', '31' => '0', '90' => '0' }
    end

    it { is_expected.to match_array [12, 42, 43, 72] }
  end

  describe 'retrieve_assistances_experts' do
    subject(:retrieve_assistances_experts) do
      described_class.retrieve_assistances_experts(assistance_expert_ids)
    end

    let(:assistances_experts) { create_list :assistance_expert, 3 }
    let(:assistance_expert_ids) { assistances_experts.map(&:id) }

    it { is_expected.to match_array assistances_experts }
  end

  describe 'assistances_grouped_by_experts' do
    subject(:assistances_grouped_by_experts) do
      described_class.assistances_grouped_by_experts(assistances_experts)
    end

    context 'when there is no assistance expert' do
      let(:assistances_experts) { [] }

      it { is_expected.to eq [] }
    end

    context 'when there is one assistance_expert' do
      let(:expert) { create :expert }
      let(:assistance) { create :assistance }
      let(:assistance_expert) { create :assistance_expert, expert: expert, assistance: assistance }

      let(:assistances_experts) { [assistance_expert] }

      it { is_expected.to eq [{ expert: expert, assistances: [assistance] }] }
    end

    context 'when there are several assistances experts' do
      let(:expert) { create :expert }

      let(:assistance1) { create :assistance }
      let(:ae1) { create :assistance_expert, expert: expert, assistance: assistance1 }

      let(:assistance2) { create :assistance }
      let(:ae2) { create :assistance_expert, expert: expert, assistance: assistance2 }

      let(:assistances_experts) { [ae1, ae2] }

      it { is_expected.to eq [{ expert: expert, assistances: [assistance1, assistance2] }] }
    end
  end

  describe 'notify_expert' do
    subject(:notify_expert) do
      described_class.notify_expert(expert_hash, user, diagnosis)
    end

    let(:expert_hash) { { expert: expert, assistances: assistances } }
    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee }
    let(:diagnosis) { create :diagnosis, visit: visit }

    let(:expert) { create :expert }
    let(:assistances) { create_list :assistance, 3 }

    let(:email_params) do
      {
        advisor: user,
        visit_date: diagnosis.visit.happened_at_localized,
        company_name: diagnosis.visit.company_name,
        company_contact: diagnosis.visit.visitee,
        assistances: assistances,
        expert_institution: expert.institution.name
      }
    end

    it do
      allow(ExpertMailer).to receive(:notify_company_needs).and_call_original

      notify_expert

      expect(ExpertMailer).to have_received(:notify_company_needs).with(expert, email_params)
    end
  end
end
