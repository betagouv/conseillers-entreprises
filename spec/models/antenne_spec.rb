require 'rails_helper'

RSpec.describe Antenne, type: :model do
  describe 'relations' do
    describe 'expert' do
      let(:active_expert) { create :expert }
      let(:deleted_expert) { create :expert, deleted_at: Time.now }
      let(:antenne) { create :antenne, experts: [active_expert, deleted_expert] }

      subject { antenne.experts }

      before { antenne.reload }

      it 'return only not deleted experts' do
        is_expected.to match [active_expert]
      end
    end

    describe 'advisor' do
      let(:active_advisor) { create :user }
      let(:deleted_advisor) { create :user, deleted_at: Time.now }
      let(:antenne) { create :antenne, advisors: [active_advisor, deleted_advisor] }

      subject { antenne.advisors }

      before { antenne.reload }

      it 'return only not deleted advisors' do
        is_expected.to match [active_advisor]
      end
    end
  end

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
      let!(:match) { create :match, expert: expert }

      it { is_expected.to eq [match] }
    end
  end

  describe 'by_antenne_and_institution_names' do
    subject(:result) { described_class.by_antenne_and_institution_names(query) }

    let(:query) { [['Agence Douai', 'Pôle emploi'], ['Agence Cambrai', 'CMA']] }

    let(:pe) { create :institution, name: 'Pôle emploi' }
    let(:cma) { create :institution, name: 'CMA' }
    let(:a1) { create :antenne, name: 'Agence Douai', institution: pe }
    let(:a2) { create :antenne, name: 'Agence Cambrai', institution: pe }
    let(:a3) { create :antenne, name: 'Agence Douai', institution: cma }
    let(:a4) { create :antenne, name: 'Agence Cambrai', institution: cma }

    before { [a1, a2, a3, a4] }

    it { is_expected.to match_array [a1, a4] }
  end
end
