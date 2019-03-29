# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:skills)
      is_expected.to have_many(:needs)
      is_expected.to belong_to :theme
      is_expected.to validate_presence_of :theme
    end
  end

  describe 'scopes' do
    describe 'ordered_for_interview' do
      subject { Subject.ordered_for_interview }

      let(:q1) { create :subject, interview_sort_order: 1 }
      let(:q3) { create :subject, interview_sort_order: 3 }
      let(:q2) { create :subject, interview_sort_order: 2 }
      let(:q0) { create :subject, interview_sort_order: 0 }
      let(:qnil) { create :subject, interview_sort_order: nil }

      it { is_expected.to eq [q0, q1, q2, q3, qnil] }
    end

    describe 'for_interview' do
      subject { Subject.for_interview }

      let(:q) { create :subject }

      before do
        create :subject, archived_at: 2.days.ago
      end

      it { is_expected.to eq [q] }
    end
  end
end
