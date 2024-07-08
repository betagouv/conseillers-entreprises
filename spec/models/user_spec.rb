# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it do
      is_expected.to have_and_belong_to_many :experts
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:job)
        is_expected.to validate_presence_of(:email)
      end
    end
  end

  describe 'relations' do
    describe 'expert' do
      context 'user can have many experts' do
        let(:user) { create :user }
        let!(:expert1) { create :expert, users: [user] }
        let!(:expert2) { create :expert, users: [user] }

        it do
          expect(user.experts).to contain_exactly(expert1, expert2)
        end
      end

      context 'user can have no expert' do
        let(:user) { create :user }

        it do
          expect(user.experts).to be_empty
        end
      end
    end
  end

  describe 'soft deletion' do
    subject(:user) { create :user }

    before { user.destroy }

    describe 'deleting user does not really destroy' do
      it { is_expected.to be_deleted }
      it { is_expected.to be_persisted }
      it { is_expected.not_to be_destroyed }
    end

    describe 'deleted users can’t login' do
      it { is_expected.not_to be_active_for_authentication }
    end

    describe 'deleted users get their attributes nilled, and full_name masked' do
      it do
        expect(user[:full_name]).to eq I18n.t('deleted_account.full_name')
        expect(user[:email]).to be_nil
        expect(user[:phone_number]).to be_nil

        expect(user.full_name).not_to be_nil
      end
    end

    describe 'feedbacks and diagnoses of deleted users still have their author / advisor' do
      let(:feedback) { create :feedback, :for_need, user: user }
      let(:diagnosis) { create :diagnosis, advisor: user }

      it do
        expect(feedback.user).to be user
        expect(diagnosis.advisor).to be user
      end
    end
  end

  describe 'scopes' do
    describe 'not_invited' do
      subject { described_class.not_invited }

      let!(:user1) { create :user, invitation_sent_at: nil }
      let!(:user2) { create :user, invitation_sent_at: DateTime.now }

      it{ is_expected.to match_array user1 }
    end

    describe "relevant_for_skills" do
      let!(:expert1) { create :expert, users: [user] }
      let!(:expert2) { create :expert, users: [user] }
      let!(:user) { create :user }

      subject(:relevant_users_for_skills) { described_class.relevant_for_skills }

      it {
        expect(relevant_users_for_skills.ids).to contain_exactly(user.id, user.id)
        expect(relevant_users_for_skills.map(&:relevant_expert)).to contain_exactly(expert1, expert2)
      }
    end

    describe 'rights scopes' do
      let(:user_advisor) { create :user }
      let(:user_manager) { create :user, :manager }
      let(:user_deleted_manager) { create :user, :manager, deleted_at: 1.day.ago }
      let(:user_admin) { create :user, :admin }
      let(:user_poly) { create :user, :admin, :manager }

      subject(:scope) { described_class.send(scope) }

      context 'admin' do
        let(:scope) { :admin }

        it{ is_expected.to contain_exactly(user_admin, user_poly) }
      end

      context 'manager' do
        let(:scope) { :managers }

        it{ is_expected.to contain_exactly(user_manager, user_poly) }
      end
    end

    describe 'omnisearch' do
      let(:user) { create :user, :invitation_accepted, email: 'a.lovelace@example.com', full_name: 'Ada Lovelace' }

      it 'finds by name' do
        expect(described_class.omnisearch("ada")).to contain_exactly(user)
        expect(described_class.omnisearch("dodo")).to be_empty
      end

      it 'finds by email' do
        expect(described_class.omnisearch("lolo@mail.com")).to be_empty
        expect(described_class.omnisearch("a.lovelace")).to contain_exactly(user)
      end
    end
  end

  describe '#password_required?' do
    subject { user.password_required? }

    context 'new user' do
      let(:user) { create :user }

      it { is_expected.to be_falsey }
    end

    context 'invitation accepted user' do
      let(:user) { create :user, :invitation_accepted }

      it { is_expected.to be_truthy }
    end
  end

  describe '#password_complexity' do
    subject { user.password_complexity }

    context '1 uppercase, 1 lower case, 1 number, 1 special car' do
      let(:user) { build :user, password: 'abAB12;;' }

      it { is_expected.to be_truthy }
    end

    context '1 uppercase, 1 lower case, 1 number' do
      let(:user) { build :user, password: 'abcABC12' }

      it { is_expected.to be_truthy }
    end

    context '1 special car, 1 lower case, 1 number' do
      let(:user) { build :user, password: 'abc***12' }

      it { is_expected.to be_truthy }
    end

    context '1 special car, 1 lower case, 1 uppercase' do
      let(:user) { build :user, password: 'abcABC°°' }

      it { is_expected.to be_truthy }
    end

    context '1 uppercase, 1 lower case' do
      let(:user) { build :user, password: 'abcdABCD' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#invitation_not_accepted?' do
    subject { user.invitation_not_accepted? }

    context 'blank user' do
      let(:user) { build :user, invitation_accepted_at: nil }

      it{ is_expected.to be_truthy }
    end

    context 'active user' do
      let(:user) { build :user, invitation_accepted_at: DateTime.now }

      it{ is_expected.to be_falsey }
    end
  end

  describe '#managed_antennes' do
    let(:user) { create :user, :manager }

    context "adding a new managed antenne" do
      let(:new_antenne) { create :antenne }

      before do
        user.managed_antennes.push(new_antenne)
      end

      it "lets user manage multiple antennes" do
        expect(user.managed_antennes.size).to eq 2
        expect(new_antenne.advisors).not_to include user
      end
    end
  end

  describe '#duplicate' do
    let(:institution) { create :institution }
    let(:antenne) { create :antenne, institution: institution }
    let(:a_subject) { create :subject }
    let(:institution_subject) { create :institution_subject, institution: institution, subject: a_subject }
    let(:expert_subject) { create :expert_subject, institution_subject: institution_subject }
    let(:old_user) { create :user, :invitation_accepted, :manager, experts: [expert], antenne: antenne, full_name: 'Old User' }

    context 'with team' do
      let(:expert) { create :expert_with_users, experts_subjects: [expert_subject], antenne: antenne }
      let(:new_user) { old_user.duplicate({ full_name: 'New User', email: 'test1@email.com', phone_number: '0303030303' }) }

      it "duplicate a user and add it to old_user team" do
        expect(new_user.full_name).to eq 'New User'
        expect(new_user.email).to eq 'test1@email.com'
        expect(new_user.phone_number).to eq '03 03 03 03 03'
        expect(new_user.job).to eq old_user.job
        expect(new_user.antenne).to eq old_user.antenne
        expect(new_user.antenne.experts.count).to eq 1
        expect(new_user.experts.map { |e| e.subjects }.flatten).to contain_exactly(a_subject)
        expect(new_user.relevant_experts).to contain_exactly(expert)
        expect(new_user.user_rights.count).to eq 1
      end
    end
  end

  describe '#reassign matches' do
    let(:institution) { create :institution }
    let(:antenne) { create :antenne, institution: institution }
    let(:a_subject) { create :subject }
    let(:institution_subject) { create :institution_subject, institution: institution, subject: a_subject }
    let(:expert_subject) { create :expert_subject, institution_subject: institution_subject }
    let(:old_expert) { create :expert, experts_subjects: [expert_subject], full_name: 'Édith Piaf', email: 'edith@email.com' }
    let(:old_user) { create :user, :invitation_accepted, experts: [old_expert], antenne: antenne, full_name: 'Édith Piaf', email: 'edith@email.com' }
    let(:new_user) { create :user, :invitation_accepted, full_name: 'David Heinemeier Hansson', email: 'david@email.com', phone_number: '0303030303' }
    let(:new_expert) { create :expert, experts_subjects: [expert_subject], full_name: 'David Heinemeier Hansson', email: 'david@email.com' }

    # Match quo OK
    let!(:match_quo) { create :match, status: :quo, expert: old_expert }
    # Match taking_care OK
    let!(:match_taking_care) { create :match, status: :taking_care, expert: old_expert }
    # Match done KO
    let!(:match_done) { create :match, status: :done, expert: old_expert }
    # Match done_no_help ko
    let!(:match_done_no_help) { create :match, status: :done_no_help, expert: old_expert }
    # Match done_not_reachable ko
    let!(:match_done_not_reachable) { create :match, status: :done_not_reachable, expert: old_expert }
    # Match not_for_me ko
    let!(:match_not_for_me) { create :match, status: :not_for_me, expert: old_expert }

    before { old_user.transfer_in_progress_matches(new_user) }

    it 'transfer matches' do
      expect(new_user.received_matches.where(need: match_quo.need, status: :quo).count).to eq 1
      expect(new_user.received_matches.where(need: match_taking_care.need, status: :taking_care).count).to eq 1
      expect(new_user.received_matches.where(need: match_done.need, status: :done).count).to eq 0
      expect(new_user.received_matches.where(need: match_done_no_help.need, status: :done_no_help).count).to eq 0
      expect(new_user.received_matches.where(need: match_done_not_reachable.need, status: :done_not_reachable).count).to eq 0
      expect(new_user.received_matches.where(need: match_not_for_me.need, status: :not_for_me).count).to eq 0
    end
  end
end
