# frozen_string_literal: true

require 'rails_helper'

describe ExpertReminderService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_reminders' do
    subject(:send_experts_reminders) { described_class.send_reminders }

    before do
      allow(SelectedAssistanceExpert).to receive(:needing_taking_care_update).and_return(sae_needing_taking_care_update)
      allow(SelectedAssistanceExpert).to receive(:with_no_one_in_charge).and_return(sae_with_no_one_in_charge)
    end

    context 'experts are different' do
      let(:sae_needing_taking_care_update) { create_list :selected_assistance_expert, 2, :with_assistance_expert }
      let(:sae_with_no_one_in_charge) { create_list :selected_assistance_expert, 2, :with_assistance_expert }

      it { expect { send_experts_reminders }.to change { Delayed::Job.count }.by(4) }
    end

    context 'expert is the same' do
      let(:expert) { create :expert }
      let(:assistance_expert) { create :assistance_expert, expert: expert }

      let(:sae_needing_taking_care_update) do
        create_list :selected_assistance_expert, 2, :with_assistance_expert, assistance_expert: assistance_expert
      end
      let(:sae_with_no_one_in_charge) do
        create_list :selected_assistance_expert, 2, :with_assistance_expert, assistance_expert: assistance_expert
      end

      it { expect { send_experts_reminders }.to change { Delayed::Job.count }.by(1) }
    end

    context 'expert is the same' do
      let(:expert) { create :expert }
      let(:assistance_expert) { create :assistance_expert, expert: expert }

      let(:sae_needing_taking_care_update) { [] }
      let(:sae_with_no_one_in_charge) { [] }

      it { expect { send_experts_reminders }.not_to(change { Delayed::Job.count }) }
    end
  end
end
