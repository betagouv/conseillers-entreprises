# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :antenne
      is_expected.to have_many(:experts_subjects)
      is_expected.to have_many :received_matches
      is_expected.to have_and_belong_to_many :users
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:antenne)
        is_expected.to validate_presence_of(:email)
      end
    end
  end

  describe 'relations' do
    describe 'users' do
      let(:active_user) { create :user, :invitation_accepted }
      let(:deleted_user) { create :user, :invitation_accepted, deleted_at: Time.now }
      let!(:expert) { create :expert, users: [deleted_user, active_user] }

      subject { expert.users }

      before { expert.reload }

      it 'return only not deleted users' do
        is_expected.to match [active_user]
      end
    end
  end

  describe 'team notions' do
    let(:user) { build :user, email: 'user@example' }
    let(:user2) { build :user, email: 'otheruser@example' }

    subject(:expert) { create :expert, email: 'user@example', users: expert_users }

    context 'an expert with a single user with the same email is a personal_skillset' do
      let(:expert_users) { [user] }

      it do
        is_expected.to be_personal_skillset
        is_expected.not_to be_team
        is_expected.not_to be_without_users
        expect(described_class.personal_skillsets).to include(expert)
        expect(described_class.teams).not_to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with a single user with a different email is a team' do
      let(:expert_users) { [user2] }

      it do
        is_expected.not_to be_personal_skillset
        is_expected.to be_team
        is_expected.not_to be_without_users
        expect(described_class.personal_skillsets).not_to include(expert)
        expect(described_class.teams).to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with several users is a team' do
      let(:expert_users) { [user, user2] }

      it do
        is_expected.not_to be_personal_skillset
        is_expected.to be_team
        is_expected.not_to be_without_users
        expect(described_class.personal_skillsets).not_to include(expert)
        expect(described_class.teams).to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with no user is neither a team nor a personal_skillset' do
      let(:expert_users) { [] }

      it do
        is_expected.not_to be_personal_skillset
        is_expected.not_to be_team
        is_expected.to be_without_users
        expect(described_class.personal_skillsets).not_to include(expert)
        expect(described_class.teams).not_to include(expert)
        expect(described_class.without_users).to include(expert)
      end
    end
  end

  describe 'a user cannot be member of the same team twice' do
    let(:user) { build :user }
    let(:expert) { build :expert }

    let(:expert_double_user) { create :expert, users: [user, user] }
    let(:user_double_expert) { create :user, experts: [expert, expert] }

    it do
      expect{ expert_double_user }.to raise_error ActiveRecord::RecordNotUnique
      expect{ user_double_expert }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'referencing' do
    describe 'commune zone scopes' do
      let(:expert_with_custom_communes) { create :expert, antenne: antenne, communes: [commune1] }
      let(:expert_without_custom_communes) { create :expert, antenne: antenne }
      let(:commune1) { create :commune }
      let(:commune2) { create :commune }
      let!(:antenne) { create :antenne, communes: [commune1, commune2] }

      describe 'with_custom_communes' do
        subject { described_class.with_custom_communes }

        it { is_expected.to include(expert_with_custom_communes) }
      end

      describe 'without_custom_communes' do
        subject { described_class.without_custom_communes }

        it { is_expected.to include(expert_without_custom_communes) }
      end
    end

    describe 'without_subjects' do
      subject(:expert) { create :expert, experts_subjects: expert_subjects }

      context 'without subject' do
        let(:expert_subjects) { [] }

        it {
          is_expected.to be_without_subjects
          expect(described_class.without_subjects).to include expert
        }
      end

      context 'with subject' do
        let(:expert_subjects) { create_list :expert_subject, 2 }

        it {
          is_expected.not_to be_without_subjects
          expect(described_class.without_subjects).not_to include expert
        }
      end
    end
  end

  describe 'soft deletion' do
    subject(:expert) { create :expert }

    before { expert.destroy }

    describe 'deleting user does not really destroy' do
      it { is_expected.to be_deleted }
      it { is_expected.to be_persisted }
      it { is_expected.not_to be_destroyed }
    end

    describe 'deleted experts get their attributes nilled, and full_name masked' do
      it do
        expect(expert[:full_name]).to be_nil
        expect(expert[:email]).to be_nil
        expect(expert[:phone_number]).to be_nil

        expect(expert.full_name).not_to be_nil
      end
    end
  end

  describe 'with_old_needs_in_inbox scope' do
    let!(:expert_with_empty_inbox) { create :expert }
    let!(:expert_with_recent_needs_in_inbox) { create :expert }
    let!(:expert_with_old_needs_in_inbox) { create :expert }
    let!(:recent_match) { create :match, expert: expert_with_recent_needs_in_inbox }
    let!(:old_match) { create :match, expert: expert_with_old_needs_in_inbox, created_at: 8.days.ago }

    it 'displays only expert with old needs in inbox' do
      expect(described_class.with_old_needs_in_inbox).to match_array [expert_with_old_needs_in_inbox]
    end
  end

  describe 'most_needs_quo_first scope' do
    let!(:expert_with_lots_inbox) { create :expert }
    let!(:expert_with_few_inbox) { create :expert }
    let!(:expert_with_few_taken_care) { create :expert }

    before do
      expert_with_lots_inbox.received_matches << [ create(:match), create(:match) ]
      expert_with_few_inbox.received_matches << [ create(:match), create(:match, status: 'taking_care'), create(:match, status: 'taking_care') ]
      expert_with_few_taken_care.received_matches << [ create(:match, status: 'taking_care'), create(:match, status: 'taking_care') ]
    end

    it 'displays expert in correct order' do
      expect(described_class.most_needs_quo_first).to eq [expert_with_lots_inbox, expert_with_few_inbox]
    end
  end
end
