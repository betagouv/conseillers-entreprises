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
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:antenne)
        is_expected.to validate_presence_of(:email)
        is_expected.to validate_presence_of(:phone_number)
      end
    end
  end

  describe 'scopes' do
    describe 'commune zone scopes' do
      let(:expert_with_custom_communes) { create :expert, antenne: antenne, communes: [commune1] }
      let(:expert_without_custom_communes) { create :expert, antenne: antenne }
      let(:commune1) { create :commune }
      let(:commune2) { create :commune }
      let!(:antenne) { create :antenne, communes: [commune1, commune2] }

      describe 'with_custom_communes' do
        subject { described_class.with_custom_communes }

        it { is_expected.to match_array [expert_with_custom_communes] }
      end

      describe 'without_custom_communes' do
        subject { described_class.without_custom_communes }

        it { is_expected.to match_array [expert_without_custom_communes] }
      end
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'should_review_subjects?' do
    subject { expert.should_review_subjects? }

    let(:expert) { create :expert, subjects_reviewed_at: reviewed_at }

    context 'subjects never reviewed' do
      let(:reviewed_at) { nil }

      it{ is_expected.to be_truthy }
    end

    context 'subjects reviewed long ago' do
      let(:reviewed_at) { 10.years.ago }

      it{ is_expected.to be_truthy }
    end

    context 'subjects reviewed recently' do
      let(:reviewed_at) { 2.days.ago }

      it{ is_expected.to be_falsey }
    end
  end
end
