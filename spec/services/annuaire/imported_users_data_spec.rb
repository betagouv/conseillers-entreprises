require 'rails_helper'

describe Annuaire::ImportedUsersData do
  describe 'primitives' do
    let(:imported_users_data) { described_class.new(instance_double(Annuaire::UsersData),[], instance_double(Annuaire::UsersData)) }

    describe '#decorate_user' do
      let(:user) { create :user, full_name: 'Some Name' }
      let(:user_2) { user.dup.tap { it.full_name = "Another name" } }

      context "new imported user" do
        before { imported_users_data.decorate_user(user, user, nil) }

        it { expect(user.import_change_type).to eq :created }
      end

      context "removed old user" do
        before { imported_users_data.decorate_user(user, nil, user) }

        it { expect(user.import_change_type).to eq :removed }
      end

      context "touched existing user" do
        before { imported_users_data.decorate_user(user, user, user) }

        it { expect(user.import_change_type).to eq :touched }
      end

      context "updated existing user" do
        before { imported_users_data.decorate_user(user_2, user_2, user) }

        it do
          expect(user_2.import_change_type).to eq :updated
          expect(user_2.import_attributes_diff).to eq [["~", "full_name", "Some Name", "Another name"]]
        end
      end
    end

    describe '#decorate_expert' do
      let(:expert) { create :expert, full_name: 'Some Name' }
      let(:expert_2) { expert.dup.tap { it.full_name = "Another name" } }

      context "new imported expert" do
        before { imported_users_data.decorate_expert(expert, expert, nil) }

        it { expect(expert.import_change_type).to eq :created }
      end

      context "removed old expert" do
        before { imported_users_data.decorate_expert(expert, nil, expert) }

        it { expect(expert.import_change_type).to eq :removed }
      end

      context "touched existing expert" do
        before { imported_users_data.decorate_expert(expert, expert, expert) }

        it { expect(expert.import_change_type).to eq :touched }
      end

      context "updated existing expert" do
        before { imported_users_data.decorate_expert(expert_2, expert_2, expert) }

        it do
          expect(expert_2.import_change_type).to eq :updated
          expect(expert_2.import_attributes_diff).to eq [["~", "full_name", "Some Name", "Another name"]]
        end
      end
    end

    describe '#decorate_expert_subject_changes' do
      let(:subject_1) { create :institution_subject }
      let(:subject_2) { create :institution_subject }
      let(:subject_3) { create :institution_subject }
      let(:institution_subjects) { [subject_1, subject_2, subject_3] }
      let(:expert) { create :expert, experts_subjects: [subject_1, subject_2].map{ create :expert_subject, institution_subject: it } }
      let(:expert_2) { create :expert, experts_subjects: [subject_1, subject_3].map{ create :expert_subject, institution_subject: it } }

      context "updated expert" do
        before { imported_users_data.decorate_expert_subject_changes(expert_2, expert_2, expert, institution_subjects) }

        it do
          expect(expert_2.import_subjects_changes).to eq({
            subject_1 => :touched,
            subject_2 => :removed,
            subject_3 => :created,
          })
        end
      end
    end

    describe '#decorate_antenne' do
      let(:antenne) { create :antenne, name: 'Some Name' }
      let(:antenne_2) { antenne.dup.tap { it.name = "Another name" } }

      context "new imported antenne" do
        before { imported_users_data.decorate_antenne(antenne, antenne, nil) }

        it { expect(antenne.import_change_type).to eq :created }
      end

      context "removed old antenne" do
        before { imported_users_data.decorate_antenne(antenne, nil, antenne) }

        it { expect(antenne.import_change_type).to eq :removed }
      end

      context "touched existing antenne" do
        before { imported_users_data.decorate_antenne(antenne, antenne, antenne) }

        it { expect(antenne.import_change_type).to eq :touched }
      end
    end
  end

  describe 'main methods' do
    let(:imported_users_data) { described_class.new(data, imported_users, old_data, filter: filter) }
    let(:filter) { :all }

    let(:institution) { create :institution }
    let(:antenne_1) { create :antenne, institution: institution }
    let(:antenne_2) { create :antenne, institution: institution }
    let(:expert_1) { create :expert, antenne: antenne_1 }
    let(:expert_2) { create :expert, antenne: antenne_1 }
    let(:expert_3) { create :expert, antenne: antenne_2 }
    let!(:user_1) { create :user, experts: [expert_1], antenne: antenne_1 }
    let!(:user_2) { create :user, experts: [expert_1], antenne: antenne_1 }
    let!(:user_3) { create :user, experts: [expert_2], antenne: antenne_1 }
    let!(:user_4) { create :user, experts: [expert_2], antenne: antenne_1 }
    let!(:user_5) { create :user, experts: [expert_3], antenne: antenne_2 }

    let(:data) do
      Annuaire::UsersData.new(institution, nil)
    end
    let(:imported_users) { [user_1, user_2, user_3] }
    let(:old_data) do
      Annuaire::UsersData.new(institution, nil).tap do |data|
        allow(data).to receive(:grouped_experts).and_return({
          antenne_1 => {
            expert_1 => [user_1],
            expert_2 => [user_4],
          },
          antenne_2 => {
            expert_3 => [user_5]
          }
        })
      end
    end

    describe '#decorate_data' do
      before do
        allow(data).to receive(:grouped_experts).and_return({
          antenne_1 => {
            expert_1 => [user_1, user_2],
            expert_2 => [user_3, user_4]
          },
          antenne_2 => {
            expert_3 => [user_5]
          }
        })
        imported_users_data.decorate_data
      end

      it do
        expect(user_1.import_change_type).to eq :touched
        expect(user_2.import_change_type).to eq :created
        expect(user_3.import_change_type).to eq :created
        expect(user_4.import_change_type).to eq :removed
        expect(user_5.import_change_type).to eq :removed
        expect(expert_1.import_change_type).to eq :touched
        expect(expert_2.import_change_type).to eq :touched
        expect(expert_3.import_change_type).to eq :removed
        expect(antenne_1.import_change_type).to eq :touched
        expect(antenne_2.import_change_type).to eq :removed
      end
    end

    describe '#aggregate_decorations' do
      before do
        allow(data).to receive(:grouped_experts).and_return({
          antenne_1 => {
            expert_1 => [user_1, user_2],
            expert_2 => [user_3, user_4]
          },
          antenne_2 => {
            expert_3 => [user_5]
          }
        })
        imported_users_data.decorate_data
        imported_users_data.aggregate_decorations
      end

      it do
        expect(expert_1.import_change_type).to eq :updated
        expect(expert_2.import_change_type).to eq :updated
        expect(expert_3.import_change_type).to eq :removed
        expect(antenne_1.import_change_type).to eq :updated
        expect(antenne_2.import_change_type).to eq :removed
      end
    end

    describe '#grouped_experts (filtered data)' do
      context ':all' do
        let(:filter) { :all }

        it {
          expect(imported_users_data.grouped_experts).to eq({
            antenne_1 => {
              expert_1 => [user_1, user_2],
              expert_2 => [user_3, user_4]
            },
            antenne_2 => {
              expert_3 => [user_5]
            }
          })
        }
      end

      context ':only_imported_users' do
        let(:filter) { :only_imported_users }

        it do
          expect(imported_users_data.grouped_experts).to eq({
            antenne_1 => {
              expert_1 => [user_1, user_2],
              expert_2 => [user_3]
            }
          })
        end
      end

      context ':referenced_antennes' do
        let(:filter) { :referenced_antennes }

        it do
          expect(imported_users_data.grouped_experts).to eq({
            antenne_1 => {
              expert_1 => [user_1, user_2],
              expert_2 => [user_3, user_4]
            }
          })
        end
      end
    end
  end
end
