require 'rails_helper'

RSpec.describe ExpertSubject, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :expert
      is_expected.to belong_to :institution_subject
    end
  end

  describe 'scopes' do
    describe 'relevant_for' do
      subject{ described_class.relevant_for(need) }

      let(:need) { create :need }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, subject: the_subject),
               expert: create(:expert, communes: communes)
      end

      context 'when the expert isn’t on the commune' do
        let(:the_subject) { need.subject }
        let(:communes) { [create(:commune)] }

        it{ is_expected.to be_blank }
      end

      context 'when the institution doesn’t handle that subject' do
        let(:the_subject) { create :subject }
        let(:communes) { [need.facility.commune] }

        it{ is_expected.to be_blank }
      end

      context 'when both subject and institution match' do
        let(:the_subject) { need.subject }
        let(:communes) { [need.facility.commune] }

        it{ is_expected.to eq [expert_subject] }
      end
    end
  end

  describe 'csv_description' do
    subject { expert_subject.csv_description }

    let(:expert_subject) { build :expert_subject, description: description }

    context 'with description' do
      let(:description) { 'Longue description du rôle' }

      it { is_expected.to eq 'Longue description du rôle' }
    end

    context 'empty description' do
      let(:description) { '' }

      it { is_expected.to eq 'oui' }
    end
  end

  describe 'csv_description=' do
    before { expert_subject.csv_description = csv }

    let(:expert_subject) { build :expert_subject, description: nil }

    context 'with description' do
      let(:csv) { 'Longue description du rôle' }

      it do
        expect(expert_subject.description).to eq 'Longue description du rôle'
      end
    end

    context 'empty description' do
      let(:csv) { 'X' }

      it do
        expect(expert_subject.description).to eq ''
      end
    end
  end
end
