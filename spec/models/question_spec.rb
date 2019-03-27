# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:assistances)
      is_expected.to have_many(:diagnosed_needs)
      is_expected.to belong_to :category
      is_expected.to validate_presence_of :category
    end
  end

  describe 'scopes' do
    describe 'ordered_for_interview' do
      subject { Question.ordered_for_interview }

      let(:q1) { create :question, interview_sort_order: 1 }
      let(:q3) { create :question, interview_sort_order: 3 }
      let(:q2) { create :question, interview_sort_order: 2 }
      let(:q0) { create :question, interview_sort_order: 0 }
      let(:qnil) { create :question, interview_sort_order: nil }

      it { is_expected.to eq [q0, q1, q2, q3, qnil] }
    end

    describe 'for_interview' do
      subject { Question.for_interview }

      let(:q) { create :question }

      before do
        create :question, archived_at: 2.days.ago
      end

      it { is_expected.to eq [q] }
    end
  end
end
