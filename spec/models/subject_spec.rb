# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject do
  describe 'associations' do
    it do
      is_expected.to have_many(:institutions_subjects)
      is_expected.to have_many(:needs)
      is_expected.to belong_to :theme
    end
  end

  describe 'compute_slug' do
    let(:theme) { create :theme, label: "My Theme" }
    let(:the_subject) { build :subject, label: "My Subject", theme: theme }

    context 'manual call' do
      before { the_subject.compute_slug }

      it { expect(the_subject.slug).to eq 'my_theme_my_subject' }
    end

    context 'before_validation hook' do
      before { the_subject.save }

      it do
        expect(the_subject.slug).to eq 'my_theme_my_subject'
        expect(the_subject).to be_valid
      end
    end

    context 'after_save hook in theme' do
      before do
        the_subject.save
        theme.reload
        theme.update label: "My Theme Renamed"
        the_subject.reload
      end

      it do
        expect(the_subject.slug).to eq 'my_theme_renamed_my_subject'
        expect(the_subject).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe 'ordered_for_interview' do
      subject { described_class.ordered_for_interview }

      let(:q1) { create :subject, interview_sort_order: 1 }
      let(:q3) { create :subject, interview_sort_order: 3 }
      let(:q2) { create :subject, interview_sort_order: 2 }
      let(:q0) { create :subject, interview_sort_order: 0 }
      let(:qnil) { create :subject, interview_sort_order: nil }

      it { is_expected.to contain_exactly(q0, q1, q2, q3, qnil) }
    end

    describe 'for_interview' do
      subject { described_class.for_interview }

      let(:q) { create :subject }

      before do
        create :subject, archived_at: 2.days.ago
        create :subject, is_support: true
      end

      it { is_expected.to contain_exactly(q) }
    end
  end

  describe 'support' do
    describe 'unicity' do
      subject { described_class.where(is_support: true) }

      before { create :subject, is_support: true }

      let!(:q2) { create :subject, is_support: true }

      it { is_expected.to contain_exactly(q2) }
    end
  end

  describe 'copy_experts_from_other' do
    let(:s1) { create :subject }
    let(:s2) { create :subject }

    let(:i1) { build :institution }
    let(:i2) { build :institution }

    let(:is1) { build :institution_subject, subject: s1, institution: i1 }

    let(:experts1) do
      create_list :expert, 3, antenne: build(:antenne, institution: i1)
    end

    let(:experts2) do
      create_list :expert, 3, antenne: build(:antenne, institution: i2)
    end

    before do
      experts1.each do |e|
        e.experts_subjects = [build(:expert_subject, institution_subject: is1)]
      end
    end

    context 'when there was no existing experts' do
      it do
        expect(s2.experts).to be_empty

        s2.copy_experts_from_other s1
        s2.reload

        expect(s1.experts).to eq(experts1)
        expect(s2.experts).to eq(experts1)
      end
    end

    context 'when there were already experts' do
      let(:is2) { build :institution_subject, subject: s2, institution: i2 }

      before do
        experts2.each do |e|
          e.experts_subjects = [build(:expert_subject, institution_subject: is2)]
        end
      end

      it do
        expect(s2.experts).to eq(experts2)

        s2.copy_experts_from_other s1
        s2.reload

        expect(s1.experts).to eq(experts1)
        expect(s2.experts).to eq(experts1)

        experts2.each(&:reload)
        expect(experts2.flat_map(&:experts_subjects)).to be_empty
      end
    end
  end
end
