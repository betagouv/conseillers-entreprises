require 'rails_helper'

describe Annuaire::UsersData do
  describe '#grouped_experts' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1, experts: [expert_1] }
    let!(:expert_1) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:expert_1_same_antenne) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, institution: institution_1 }
    let!(:expert_2) { create :expert, :with_expert_subjects, antenne: antenne_2 }
    let!(:antenne_3) { create :antenne, institution: institution_1 }
    let!(:manager_1) { create :user, antenne: antenne_3, managed_antennes: [antenne_3] }
    let!(:manager_2) { create :user, antenne: antenne_3, managed_antennes: [antenne_3] }
    let!(:user_3) { create :user, antenne: antenne_3 }
    let!(:user_4) { create :user, antenne: antenne_3 }
    let!(:antenne_4) { create :antenne, institution: institution_1 }

    context 'for the full institution' do
      subject { described_class.new(institution_1, nil) }

      it 'return all users for the institution' do
        expect(subject.grouped_experts).to eq({
          antenne_1 => {
            expert_1 => [user_1],
            expert_1_same_antenne => [Annuaire::NO_USER]
          },
          antenne_2 => {
            expert_2 => [Annuaire::NO_USER]
          },
          antenne_3 => {
            Annuaire::NO_EXPERT => [manager_1, manager_2, user_3, user_4]
          },
          antenne_4 => {
            Annuaire::NO_EXPERT => [Annuaire::NO_USER]
          }
        })
      end
    end

    context 'with an antenne params' do
      subject { described_class.new(institution_1, antenne_1) }

      it 'returns only users for the antenne' do
        expect(subject.grouped_experts).to eq({
          antenne_1 => {
            expert_1 => [user_1],
            expert_1_same_antenne => [Annuaire::NO_USER]
          }
        })
      end
    end
  end

  describe '#retrieve_antennes_without_experts' do
    subject { described_class.new(institution, nil).retrieve_antennes_without_experts }

    let(:institution) { create :institution }
    let!(:antenne_with_expert) { create :antenne, institution: institution, experts: [create(:expert)] }
    let!(:antenne_without_experts) { create :antenne, institution: institution }
    let!(:antenne_without_experts_with_users) { create :antenne, institution: institution, advisors: [user] }
    let!(:user) { create(:user) }

    it 'return the empty antennes' do
      expect(subject.keys).to contain_exactly(antenne_without_experts, antenne_without_experts_with_users)
      expect(subject).to eq({
        antenne_without_experts => { Annuaire::NO_EXPERT => [Annuaire::NO_USER] },
        antenne_without_experts_with_users => { Annuaire::NO_EXPERT => [user] }
      })
    end
  end

  describe '#retrieve_users_without_experts' do
    subject { described_class.new(antenne.institution, antenne).retrieve_users_without_experts([antenne]) }

    let!(:antenne) { create(:antenne) }

    let!(:user_without_experts) { create(:user, antenne: antenne) }
    let!(:other_user_without_experts) { create(:user, antenne: antenne) }
    let!(:user_with_experts) { create(:user, antenne: antenne, experts: [create(:expert)]) }
    let!(:manager) { create(:user, antenne: antenne, managed_antennes: [create(:antenne)]) }

    it 'adds only users without experts' do
      expect(subject[antenne][Annuaire::NO_EXPERT]).to contain_exactly(user_without_experts, other_user_without_experts)
    end
  end

  describe '#retrieve_managers_without_experts' do
    subject { described_class.new(antenne.institution, antenne).retrieve_managers_without_experts([antenne]) }

    let(:antenne) { create(:antenne) }
    let!(:manager_with_experts) { create(:user, :manager, antenne: antenne, experts: [create(:expert)]) }
    let!(:manager_without_experts) { create(:user, :manager, antenne: antenne) }
    let!(:other_manager_without_experts) { create(:user, :manager, antenne: antenne) }

    it 'adds managers without experts' do
      expect(subject[antenne][Annuaire::NO_EXPERT]).to contain_exactly(manager_without_experts, other_manager_without_experts)
    end
  end
end
