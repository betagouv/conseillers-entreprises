# frozen_string_literal: true

require 'rails_helper'

describe DiagnosisHelper, type: :helper do
  describe 'classes_for_step' do
    subject { helper.classes_for_step(displayed_step, current_step) }

    let(:displayed_step) { 2 }

    context 'displayed step < current_step' do
      let(:current_step) { 3 }

      it { is_expected.to eq 'completed' }
    end

    context 'displayed step = current_step' do
      let(:current_step) { 2 }

      it { is_expected.to eq 'active' }
    end

    context 'displayed step > current_step' do
      let(:current_step) { 1 }

      it { is_expected.to be_nil }
    end
  end

  describe 'categories_with_questions' do
    subject { helper.categories_with_questions }

    context 'one category and question' do
      it do
        category = create :category, label: 'First category'
        question = create :question, category: category
        is_expected.to eq [{ category: 'First category', questions: [question] }]
      end
    end

    context 'two categories with questions' do
      let(:first_category) { create :category }
      let!(:first_category_questions) { create_list :question, 2, category: first_category }
      let(:second_category) { create :category }
      let!(:second_category_question) { create :question, category: second_category }

      let(:expected_array) do
        [
          {
            category: first_category.label,
            questions: first_category_questions
          },
          {
            category: second_category.label,
            questions: [second_category_question]
          }
        ]
      end

      it { is_expected.to eq expected_array }
    end
  end
end
