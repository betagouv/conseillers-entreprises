require 'rails_helper'

RSpec.describe SubjectAnswer do
  describe 'scopes' do
    describe ':ordered' do
      subject { described_class.ordered }

      let(:q1) { build :subject_question, position: 1 }
      let(:q3) { build :subject_question, position: 3 }
      let(:q2) { build :subject_question, position: 2 }
      let(:q0) { build :subject_question, position: 0 }
      let!(:a1) { create :subject_answer, subject_question: q1 }
      let!(:a2) { create :subject_answer, subject_question: q2 }
      let!(:a3) { create :subject_answer, subject_question: q3 }
      let!(:a0) { create :subject_answer, subject_question: q0 }

      it { is_expected.to contain_exactly(a0, a1, a2, a3) }
    end
  end
end
