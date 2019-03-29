require 'rails_helper'

RSpec.describe Antenne, type: :model do
  describe 'name code uniqueness' do
    subject { build :antenne, name: name, institution: institution }

    let(:name) { 'Nice Company Name' }
    let(:other_name) { 'Other Name' }
    let(:institution) { build :institution }
    let(:other_institution) { build :institution }

    context 'unique name' do
      before { create :antenne, name: other_name, institution: institution }

      it { is_expected.to be_valid }
    end

    context 'reused name' do
      before { create :antenne, name: name, institution: institution }

      it { is_expected.not_to be_valid }
    end

    context 'same name, another institution' do
      before { create :antenne, name: name, institution: other_institution }

      it { is_expected.to be_valid }
    end
  end

  describe 'sent_matches' do
    subject { antenne.sent_matches }

    let(:antenne) { build :antenne }

    context 'no match' do
      it { is_expected.to eq [] }
    end

    context 'match' do
      let(:user) { build :user, antenne: antenne }
      let!(:match) do
        create :match,
          need: build(:need,
            diagnosis: build(:diagnosis, advisor: user))
      end

      it { is_expected.to eq [match] }
    end
  end

  describe 'received_matches' do
    subject { antenne.received_matches }

    let(:antenne) { build :antenne }

    context 'no match' do
      it { is_expected.to eq [] }
    end

    context 'match' do
      let(:expert) { build :expert, antenne: antenne }
      let(:expert_skill) { build :expert_skill, expert: expert }
      let!(:match) { create :match, expert_skill: expert_skill }

      it { is_expected.to eq [match] }
    end
  end
end
