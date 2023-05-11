# frozen_string_literal: true

require 'rails_helper'

describe SubjectCoverService do
  describe '#detect_anomalie' do
    let(:institution) { create(:institution) }
    let(:subject1) { create(:subject) }
    let!(:institution_subject1) { create(:institution_subject, institution: institution, subject: subject1) }
    let!(:antenne) { create(:antenne, institution: institution) }

    subject { described_class.new.send(:detect_anomalie, antenne, subject1) }

    context 'when the subject is covered' do
      let!(:expert) { create(:expert, antenne: antenne) }
      let!(:expert_subject1) { create(:expert_subject, expert: expert, institution_subject: institution_subject1) }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when the subject is not covered' do
      let!(:expert) { create(:expert, antenne: antenne) }

      it 'returns less' do
        is_expected.to eq(:less)
      end
    end

    context 'when the subject is not covered by specifics territories' do
      let!(:commune1) { create(:commune) }
      let!(:commune2) { create(:commune) }
      let!(:expert) { create(:expert, antenne: antenne, communes: [commune1]) }

      before { antenne.communes = [commune1, commune2] }

      it 'returns less_specific' do
        is_expected.to eq(:less_specific)
      end
    end

    context 'whene there is more than one expert with specific territories on a subject' do
      let!(:commune1) { create(:commune) }
      let!(:commune2) { create(:commune) }
      let!(:expert1) { create(:expert, antenne: antenne, communes: [commune1, commune2]) }
      let!(:expert2) { create(:expert, antenne: antenne, communes: [commune1]) }
      let!(:expert_subject) { create(:expert_subject, expert: expert1, institution_subject: institution_subject1) }
      let!(:expert_subject2) { create(:expert_subject, expert: expert2, institution_subject: institution_subject1) }

      it 'returns more' do
        is_expected.to eq(:more_specific)
      end
    end

    context 'whene there is more than one expert on a subject' do
      let!(:expert1) { create(:expert, antenne: antenne) }
      let!(:expert2) { create(:expert, antenne: antenne) }
      let!(:expert_subject) { create(:expert_subject, expert: expert1, institution_subject: institution_subject1) }
      let!(:expert_subject2) { create(:expert_subject, expert: expert2, institution_subject: institution_subject1) }

      it 'returns more' do
        is_expected.to eq(:more)
      end
    end
  end
end
