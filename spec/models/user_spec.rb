# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it do
      is_expected.to have_and_belong_to_many :experts
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
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
        is_expected.to match [active_expert, user.personal_skillsets.first]
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
        expect(user[:full_name]).to be_nil
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
    describe 'not_admin' do
      it do
        create :user, is_admin: true
        regular_user = create :user, is_admin: false

        expect(described_class.not_admin).to eq [regular_user]
      end
    end

    describe 'active_searchers' do
      it do
        searcher = create :user, searches: [(create :search, created_at: 1.day.ago)]
        create :user, searches: [(create :search, created_at: 2.months.ago)]

        last_30_days = (30.days.ago)..Time.zone.now
        expect(described_class.active_searchers(last_30_days)).to eq [searcher]
      end
    end

    describe 'active_diagnosers' do
      it do
        diagnosis = create :diagnosis, created_at: 1.day.ago, step: :visit, needs: create_list(:need, 1)
        diagnoser = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_diagnosers(last_30_days, 3)).to eq [diagnoser]
        expect(described_class.active_diagnosers(last_30_days, 4)).to eq []
      end
    end

    describe 'active_answered' do
      it do
        expert = create :match, status: 'done'
        need = create :need, matches: [expert]
        diagnosis = create :diagnosis, created_at: 1.day.ago, needs: [need]
        active_user = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_answered(last_30_days, ['taking_care','done'])).to eq [active_user]
        expect(described_class.active_answered(last_30_days, ['not_for_me'])).to eq []
      end
    end

    describe 'never_used' do
      subject { described_class.never_used }

      let!(:user1) { create :user, invitation_sent_at: nil, encrypted_password: '' }
      let!(:user2) { create :user, invitation_sent_at: DateTime.now, encrypted_password: 'password' }

      it{ is_expected.to match_array user1 }
    end
  end

  describe "relevant_for_skills" do
    let!(:expert1) { create :expert, users: [user] }
    let!(:expert2) { create :expert, users: [user] }
    let!(:user) { create :user }

    subject(:relevant_users_for_skills) { described_class.relevant_for_skills }

    it {
      expect(relevant_users_for_skills.ids).to eq [user.id, user.id]
      expect(relevant_users_for_skills.map(&:relevant_expert)).to match_array [expert1, expert2]
    }
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

  describe '#never_used_account?' do
    subject { user.never_used_account? }

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

  describe 'invited_seven_days_ago' do
    # Utilisateur invité il y a 6 jours KO
    let!(:user_1) { create :user, created_at: 6.days.ago, invitation_sent_at: 6.days.ago }
    # Utilisateur invité il y a 7 jours n’ayant pas accepté l’invitation OK
    let!(:user_2) { create :user, created_at: 7.days.ago, invitation_sent_at: 7.days.ago }
    # Utilisateur invité il y a 7 jours ayant accepté l’invitation KO
    let!(:user_3) { create :user, created_at: 7.days.ago, invitation_sent_at: 7.days.ago, invitation_accepted_at: Time.zone.now }
    # Utilisateur supprimé invité il y a 7 jours KO
    let!(:user_4) { create :user, created_at: 7.days.ago, invitation_sent_at: 7.days.ago, deleted_at: Time.zone.now, invitation_accepted_at: Time.zone.now }
    # Utilisateur invité il y a 8 jours n’ayant pas accepté l’invitation KO
    let!(:user_5) { create :user, created_at: 8.days.ago, invitation_sent_at: 8.days.ago }
    # Utilisateur invité il y a 8 jours ayant accepté l’invitation KO
    let!(:user_6) { create :user, created_at: 8.days.ago, invitation_sent_at: 8.days.ago, invitation_accepted_at: Time.zone.now }

    subject { described_class.invited_seven_days_ago }

    it 'get users who were invited 7 days ago and did not accept the invitation' do
      is_expected.to eq [user_2]
    end
  end
end
