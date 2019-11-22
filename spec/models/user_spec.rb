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
        is_expected.to validate_presence_of(:phone_number)
      end
    end

    describe 'emails' do
      it do
        is_expected.to validate_presence_of(:email)
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.not_to allow_value('test').for(:email)
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
      let(:feedback) { create :feedback, user: user }
      let(:diagnosis) { create :diagnosis, advisor: user }

      it do
        expect(feedback.user).to be user
        expect(diagnosis.advisor).to be user
      end
    end
  end

  describe 'deactivation' do
    subject(:user) { create :user }

    before { user.deactivate! }

    describe 'deactivated users can’t login' do
      it { is_expected.not_to be_active_for_authentication }
    end

    describe 'reactivated users can login' do
      before { user.reactivate! }

      it { is_expected.to be_active_for_authentication }
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
        diagnosis = create :diagnosis, created_at: 1.day.ago, step: 3
        diagnoser = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_diagnosers(last_30_days, 3)).to eq [diagnoser]
        expect(described_class.active_diagnosers(last_30_days, 4)).to eq []
      end
    end

    describe 'active_answered' do
      it do
        expert = create :match, status: 2
        need = create :need, matches: [expert]
        diagnosis = create :diagnosis, created_at: 1.day.ago, needs: [need]
        active_user = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(described_class.active_answered(last_30_days, [1,2])).to eq [active_user]
        expect(described_class.active_answered(last_30_days, [3])).to eq []
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

  describe 'full_name_with_role' do
    let(:user) do
      build :user,
            full_name: 'Ivan Collombet',
            role: 'Business Developer',
            antenne: build(:antenne, name: 'DINSIC')
    end

    it { expect(user.full_name_with_role).to eq 'Ivan Collombet - Business Developer - DINSIC' }
  end

  describe '#corresponding_experts' do
    subject { user.corresponding_experts }

    let(:user) { create(:user, email: 'user@example.com') }

    before { create :expert, email: expert_email }

    context ('with a corresponding email') do
      let(:expert_email) { 'user@example.com' }

      it { is_expected.not_to be_empty }
    end

    context ('with a different email') do
      let(:expert_email) { 'lol@nope.com' }

      it { is_expected.to be_empty }
    end
  end

  describe '#corresponding_antenne' do
    subject { user.corresponding_antenne }

    let(:user) { create(:user, email: 'user@example.com') }
    let!(:antenne) { create :antenne, name: antenne_name }

    context ('matching by experts email') do
      let(:antenne_name) { 'other' }

      before { create :expert, email: expert_email, antenne: antenne }

      context ('with a corresponding email') do
        let(:expert_email) { 'user@example.com' }

        it { is_expected.to eq antenne }
      end

      context ('with a different email') do
        let(:expert_email) { 'lol@nope.com' }

        it { is_expected.to be_nil }
      end

      context ('with several matching email') do
        let(:expert_email) { 'user@example.com' }

        before { create(:expert, email: expert_email, antenne: create(:antenne)) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#is_oneself?' do
    subject { user.is_oneself? }

    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:expert1) { create(:expert) }
    let(:expert2) { create(:expert) }

    context ('with no expert') do
      before { user.experts = [] }

      it { is_expected.to be_falsey }
    end

    context ('with one expert') do
      before { expert1.users = [user] }

      it { is_expected.to be_truthy }
    end

    context ('with several experts') do
      before { user.experts = [expert1, expert2] }

      it { is_expected.to be_falsey }
    end

    context ('with one expert, several users') do
      before { expert1.users = [user, user2] }

      it { is_expected.to be_falsey }
    end
  end
end
