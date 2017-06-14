# frozen_string_literal: true

require 'rails_helper'

describe DiagnosisHelper, type: :helper do
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
      let(:first_category) { create :category, label: 'First category' }
      let!(:first_category_questions) { create_list :question, 2, category: first_category }
      let(:second_category) { create :category, label: 'Second category' }
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
