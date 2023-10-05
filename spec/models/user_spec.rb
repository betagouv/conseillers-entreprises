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
      let(:active_expert) { create :expert }
      let(:deleted_expert) { create :expert, deleted_at: Time.now }
      let(:user) { create :user, :invitation_accepted, experts: [active_expert, deleted_expert] }

      subject { user.experts }

      before { user.reload }

      it 'return only not deleted experts' do
        is_expected.to contain_exactly(active_expert, user.personal_skillsets.first)
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

    describe 'soft delete skillset if user is deleted' do
      let(:skillset) { create :expert, email: 'user@email.com', users: [] }
      let!(:user) { create :user, email: 'user@email.com', experts: [skillset] }

      it { expect(skillset.reload).to be_deleted }
    end
  end

  describe 'scopes' do
    describe 'active_searchers' do
      it do
        searcher = create :user, searches: [(create :search, created_at: 1.day.ago)]
        create :user, searches: [(create :search, created_at: 2.months.ago)]

        last_30_days = (30.days.ago)..Time.zone.now
        expect(described_class.active_searchers(last_30_days)).to contain_exactly(searcher)
      end
    end

    describe 'active_diagnosers' do
      it do
        diagnosis = create :diagnosis, created_at: 1.day.ago, step: :needs, needs: create_list(:need, 1)
        diagnoser = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_diagnosers(last_30_days, 3)).to contain_exactly(diagnoser)
        expect(described_class.active_diagnosers(last_30_days, 4)).to be_empty
      end
    end

    describe 'active_answered' do
      it do
        expert = create :match, status: 'done'
        need = create :need, matches: [expert]
        diagnosis = create :diagnosis, created_at: 1.day.ago, needs: [need]
        active_user = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_answered(last_30_days, ['taking_care','done'])).to contain_exactly(active_user)
        expect(described_class.active_answered(last_30_days, ['not_for_me'])).to be_empty
      end
    end

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

  describe '#create_personal_skillset_if_needed' do
    context 'new user creation' do
      let(:user) { create :user }

      it 'automatically adds a personal skillset' do
        expect(user.experts).not_to be_empty
        expect(user.experts.first).to be_without_subjects
        expect(user.experts.first).to be_personal_skillset
      end
    end

    context 'user part of a team' do
      let(:team) { create :expert }
      let(:user) { create :user, experts: [team] }

      it 'automaticallys adds a personal skillset' do
        expect(user.experts.count).to eq 2
      end
    end

    context 'user already with a personal skillset' do
      let(:skillset) { create :expert, email: 'user@email.com', users: [] }
      let(:user) { create :user, email: 'user@email.com', experts: [skillset] }

      it 'does not automatically add a personal skillset' do
        expect(user.experts.count).to eq 1
      end
    end
  end

  describe '#synchronize_personal_skillsets' do
    context 'user with skillsets' do
      let(:user) { create :user, email: 'user@email.com', full_name: 'Bob', experts: [personal_skillset, team] }
      let(:personal_skillset) { create :expert, email: 'user@email.com', full_name: 'Bob', users: [] }
      let(:team) { create :expert, email: 'team@email.com', full_name: 'Team' }

      before do
        user.update(full_name: 'Robert')
      end

      it 'automatically synchronizes the info in the personal skillsets' do
        expect(user.reload.full_name).to eq 'Robert'
        expect(personal_skillset.reload.full_name).to eq 'Robert'
        expect(team.reload.full_name).not_to eq 'Robert'
      end
    end

    context 'user without skillsets' do
      let(:user) { create :user, email: 'user@email.com', full_name: 'Bob', experts: [team] }
      let(:team) { create :expert, email: 'team@email.com', full_name: 'Team' }

      before do
        user.update(full_name: 'Robert')
      end

      it 'automatically synchronizes the info in the personal skillsets' do
        expect(user.reload.full_name).to eq 'Robert'
        expect(user.personal_skillsets).not_to be_empty
        expect(user.personal_skillsets.first.full_name).to eq 'Robert'
        expect(team.reload.full_name).not_to eq 'Robert'
      end
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
      let(:expert) { create :expert_with_users, experts_subjects: [expert_subject] }
      let(:new_user) { old_user.duplicate({ full_name: 'New User', email: 'test1@email.com', phone_number: '0303030303' }) }

      it "duplicate a user and add it to old_user team" do
        expect(new_user.full_name).to eq 'New User'
        expect(new_user.email).to eq 'test1@email.com'
        expect(new_user.phone_number).to eq '03 03 03 03 03'
        expect(new_user.job).to eq old_user.job
        expect(new_user.antenne).to eq old_user.antenne
        expect(new_user.antenne.experts.count).to eq 2
        expect(new_user.experts.map { |e| e.subjects }.flatten).to contain_exactly(a_subject)
        expect(new_user.relevant_experts).to contain_exactly(expert)
        expect(new_user.user_rights.count).to eq 1
      end
    end

    context 'with personal expert' do
      let(:commune) { create :commune }
      let(:expert) { create :expert, experts_subjects: [expert_subject], full_name: 'Édith Piaf', email: 'test2@email.com', communes: [commune] }
      let(:old_user) { create :user, :invitation_accepted, :manager, experts: [expert], antenne: antenne, full_name: 'Édith Piaf', email: 'test2@email.com' }
      let(:new_user) { old_user.duplicate({ full_name: 'Bruce Benamran', email: 'test3@email.com', phone_number: '0303030303', specifics_territories: '1' }) }

      it "duplicate a user and add subjects to his personnal expert" do
        expect(new_user.full_name).to eq 'Bruce Benamran'
        expect(new_user.email).to eq 'test3@email.com'
        expect(new_user.phone_number).to eq '03 03 03 03 03'
        expect(new_user.job).to eq old_user.job
        expect(new_user.antenne).to eq old_user.antenne
        expect(new_user.experts.map { |e| e.subjects }.flatten).to contain_exactly(a_subject)
        expect(new_user.relevant_experts).to contain_exactly(new_user.personal_skillsets.first)
        expect(new_user.user_rights.count).to eq 1
        expect(new_user.relevant_experts.map(&:communes).flatten).to contain_exactly(commune)
      end
    end

    context 'with accidentally existing user' do
      let(:commune) { create :commune }
      let(:expert) { create :expert, experts_subjects: [expert_subject], full_name: 'Édith Piaf', email: 'test2@email.com', communes: [commune] }
      let!(:old_user) { create :user, :invitation_accepted, :manager, experts: [expert], antenne: antenne, full_name: 'Édith Piaf', email: 'test2@email.com' }
      let!(:existing_user) { create :user, full_name: 'Bruce Benamran', email: 'test3@email.com', phone_number: '0303030303' }
      let(:new_user) { old_user.duplicate({ full_name: 'Bruce Benamran', email: 'test3@email.com', phone_number: '0303030303', specifics_territories: '1' }) }

      it "doesnt duplicate user and raises no exception" do
        expect(new_user.valid?).to be false
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
