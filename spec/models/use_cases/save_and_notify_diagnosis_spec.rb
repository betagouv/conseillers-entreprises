# frozen_string_literal: true

require 'rails_helper'

describe UseCases::SaveAndNotifyDiagnosis do
  describe 'perform' do
    subject(:save_and_notify) { described_class.perform diagnosis, selected_assistances_experts }

    let(:diagnosis) { create :diagnosis }
    let(:relay) { create :relay }

    before do
      allow(UseCases::CreateSelectedAssistancesExperts).to receive(:perform)
      allow(ExpertMailersService).to receive(:delay) { ExpertMailersService }
      allow(ExpertMailersService).to receive(:send_assistances_email)

      allow(Relay).to receive(:of_diagnosis_location).with(diagnosis).and_return [relay]
      allow(UseCases::CreateSelectedRelays).to receive(:perform)
      allow(ExpertMailersService).to receive(:delay) { ExpertMailersService }
      allow(ExpertMailersService).to receive(:send_relay_assistances_email)
    end

    context 'some experts are selected' do
      let(:selected_assistances_experts) do
        {
          assistances_experts: { '12' => '1', '90' => '0' },
          diagnosed_needs: { '31' => '1', '78' => '0' }
        }
      end
      let(:assistance_expert_ids) { [12] }
      let(:diagnosed_need_ids) { [31] }

      before { save_and_notify }

      it 'has called the right methods' do
        expect(UseCases::CreateSelectedAssistancesExperts).to have_received(:perform).with diagnosis,
                                                                                           assistance_expert_ids
        expect(UseCases::CreateSelectedRelays).to have_received(:perform).with relay,
                                                                               diagnosed_need_ids
      end

      it 'sends emails' do
        expect(ExpertMailersService).to have_received(:send_assistances_email).with(
          advisor: diagnosis.visit.advisor, diagnosis: diagnosis, assistance_expert_ids: assistance_expert_ids
        )
        expect(ExpertMailersService).to have_received(:send_relay_assistances_email).with(
          relay: relay, diagnosed_need_ids: diagnosed_need_ids,
          advisor: diagnosis.visit.advisor, diagnosis: diagnosis
        )
      end
    end

    context 'no experts are selected' do
      let(:selected_assistances_experts) do
        {
          assistances_experts: { '12' => '0', '90' => '0' },
          diagnosed_needs: { '31' => '0', '78' => '0' }
        }
      end

      before { save_and_notify }

      it 'does not call the use case methods' do
        expect(UseCases::CreateSelectedAssistancesExperts).not_to have_received(:perform)
        expect(UseCases::CreateSelectedRelays).not_to have_received(:perform)
      end

      it 'does not send emails' do
        expect(ExpertMailersService).not_to have_received(:send_assistances_email)
        expect(ExpertMailersService).not_to have_received(:send_relay_assistances_email)
      end
    end

    context 'empty hash' do
      let(:selected_assistances_experts) { {} }

      before { save_and_notify }

      it 'does not call the use case methods' do
        expect(UseCases::CreateSelectedAssistancesExperts).not_to have_received(:perform)
        expect(UseCases::CreateSelectedRelays).not_to have_received(:perform)
      end

      it 'does not send emails' do
        expect(ExpertMailersService).not_to have_received(:send_assistances_email)
        expect(ExpertMailersService).not_to have_received(:send_relay_assistances_email)
      end
    end
  end
end
