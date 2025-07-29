require 'rails_helper'
RSpec.describe AddSharedSatisfactionsJob do

  describe 'perform' do
    let(:regional_antenne) { create :antenne, :regional }
    let(:local_antenne) { create :antenne, parent_antenne: regional_antenne }
    let(:user) { create :user, antenne: local_antenne }
    let(:expert) { create :expert, antenne: local_antenne, users: [user] }
    let(:manager) { create :user, antenne: regional_antenne }

    let(:need_1) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
    let(:company_satisfaction_1) { create :company_satisfaction, need: need_1 }
    let!(:shared_expert_satisfaction_1) { create :shared_satisfaction, company_satisfaction: company_satisfaction_1, user: user, expert: expert }

    context 'managing local antenne' do
      before do
        manager.managed_antennes.push(local_antenne)
      end

      context 'not yet shared satisfaction' do
        it 'creates retroactively shared satisfactions' do
          expect { described_class.perform_now(manager.id) }.to change(manager.shared_satisfactions.reload, :count).by(1)
        end
      end

      context 'already shared satisfaction' do
        let!(:shared_expert_satisfaction_2) { create :shared_satisfaction, company_satisfaction: company_satisfaction_1, user: manager }

        it 'doesnt create retroactively shared satisfactions' do
          expect { described_class.perform_now(manager.id) }.not_to change(manager.shared_satisfactions.reload, :count)
        end
      end
    end

    context 'managing regional antenne' do
      before do
        manager.managed_antennes.push(regional_antenne)
      end

      context 'not yet shared satisfaction' do
        it 'creates retroactively shared satisfactions' do
          expect { described_class.perform_now(manager.id) }.to change(manager.shared_satisfactions.reload, :count).by(1)
        end
      end
    end
  end
end
