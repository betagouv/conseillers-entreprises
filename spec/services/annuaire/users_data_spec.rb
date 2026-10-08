require 'rails_helper'

describe Annuaire::UsersData do
  describe '#filtered_experts and #grouped_experts' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1, experts: [expert_1] }
    let!(:expert_1) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:expert_1_same_antenne) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, institution: institution_1 }
    let!(:expert_2) { create :expert, :with_expert_subjects, antenne: antenne_2 }

    context 'with an antenne params' do
      subject { described_class.new(institution_1, antenne_1) }

      it 'return all users for the antenne' do
        expect(subject.filtered_experts).to contain_exactly(expert_1, expert_1_same_antenne)
        expect(subject.group_experts.keys).to contain_exactly(antenne_1)
        expect(subject.group_experts[antenne_1].keys).to contain_exactly(expert_1, expert_1_same_antenne)
      end
    end

    context 'with an institution params' do
      subject { described_class.new(institution_1, nil) }

      it 'return all users for the institution' do
        filtered_experts = subject.filtered_experts
        expect(filtered_experts).to contain_exactly(expert_1, expert_1_same_antenne, expert_2)
        grouped_experts = subject.group_experts
        expect(grouped_experts.keys).to contain_exactly(antenne_1, antenne_2)
        expect(grouped_experts[antenne_1].keys).to contain_exactly(expert_1, expert_1_same_antenne)
        expect(grouped_experts[antenne_2].keys).to contain_exactly(expert_2)
      end
    end

    context 'with a manager without experts' do
      let!(:manager) { create :user, antenne: antenne_1 }

      before do
        manager.managed_antennes.push(antenne_1)
      end

      subject { described_class.new(institution_1, nil) }

      it 'return all users for the institution' do
        subject.retrieve_experts_and_users
        grouped_experts = subject.grouped_experts
        expect(grouped_experts.keys).to contain_exactly(antenne_1, antenne_2)
        expect(grouped_experts[antenne_1].keys).to contain_exactly(
          expert_1_same_antenne,
          expert_1,
          an_instance_of(Expert).and(have_attributes(id: nil))
        )
        expect(grouped_experts[antenne_2].keys).to contain_exactly(expert_2)
        all_users = grouped_experts.values.map(&:values).flatten
        expect(all_users).to contain_exactly(
          an_instance_of(User).and(have_attributes(id: nil)),
          user_1,
          manager,
          an_instance_of(User).and(have_attributes(id: nil))
        )
      end
    end
  end

  describe "additional methods" do
    subject { described_class.new(antenne.institution, antenne) }

    describe '#retrieve_users_without_experts' do
      let(:antenne) { create(:antenne) }
      let(:user_with_experts) { create(:user, antenne: antenne) }
      let!(:user_without_experts) { create(:user, antenne: antenne) }
      let!(:expert) { create(:expert, users: [user_with_experts]) }
      # let(:grouped_experts) { { antenne => {} } }

      context 'normal user' do
        it 'adds users without experts' do
          result = subject.retrieve_users_without_experts([antenne])
          expect(result[antenne].keys).to include(an_instance_of(Expert))
          expect(result[antenne].first.last).to include(user_without_experts)
        end

        it 'does not add users with experts' do
          result = subject.retrieve_users_without_experts([antenne])
          expect(result[antenne].keys).not_to include(expert)
        end
      end

      context 'manager' do
        let!(:manager) { create(:user, antenne: antenne, managed_antennes: [create(:antenne)]) }

        it 'does not add users who manage other antennes' do
          result = subject.retrieve_users_without_experts([antenne])
          expect(result[antenne].first.last).not_to include(manager)
        end
      end
    end

    describe '#retrieve_managers_without_experts' do
      let(:antenne) { create(:antenne) }
      let(:manager_with_experts) { create(:user, :manager, antenne: antenne) }
      let!(:manager_without_experts) { create(:user, :manager, antenne: antenne) }
      let!(:expert) { create(:expert, users: [manager_with_experts]) }
      # let(:grouped_experts) { { antenne => {} } }

      it 'adds managers without experts' do
        managers_without_experts = subject.retrieve_managers_without_experts([antenne])
        expect(managers_without_experts[antenne].keys).to include(an_instance_of(Expert))
        expect(managers_without_experts[antenne].first.last).to include(manager_without_experts)
      end

      it 'does not add managers with experts' do
        managers_without_experts = subject.retrieve_managers_without_experts([antenne])
        expect(managers_without_experts[antenne].keys).not_to include(expert)
      end
    end
  end
end
