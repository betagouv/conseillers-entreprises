# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetStep2Data do
  describe 'for_diagnosis' do
    subject { described_class.for_diagnosis diagnosis }

    let(:diagnosis) { create :diagnosis }

    let(:category1) { create :category }
    let(:category2) { create :category }
    let(:question1) { create :question, category: category1 }
    let(:question2) { create :question, category: category1 }
    let(:question3) { create :question, category: category2 }

    context 'no diagnosed_need' do
      let!(:expected_array) do
        [
          {
            category: category1.label,
                    questions: [
                      {
                        question_id: question1.id,
                        label: question1.label,
                        is_selected: false,
                        diagnosed_need_id: nil,
                        content: nil
                      },
                      {
                        question_id: question2.id,
                        label: question2.label,
                        is_selected: false,
                        diagnosed_need_id: nil,
                        content: nil
                      }
                    ]
          },
          {
            category: category2.label,
            questions: [
              {
                question_id: question3.id,
                label: question3.label,
                is_selected: false,
                diagnosed_need_id: nil,
                content: nil
              }
            ]
          }
        ]
      end

      it { is_expected.to eq expected_array }
    end

    context 'some diagnosed_needs' do
      let(:diagnosed_need1) { create :diagnosed_need, diagnosis: diagnosis, question: question1, content: 'Content' }
      let(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis, content: 'Pas Content' }

      let!(:expected_array) do
        [
          {
            category: category1.label,
                    questions: [
                      {
                        question_id: question1.id,
                        label: question1.label,
                        is_selected: true,
                        diagnosed_need_id: diagnosed_need1.id,
                        content: 'Content'
                      },
                      {
                        question_id: question2.id,
                        label: question2.label,
                        is_selected: false,
                        diagnosed_need_id: nil,
                        content: nil
                      }
                    ]
          },
          {
            category: category2.label,
            questions: [
              {
                question_id: question3.id,
                label: question3.label,
                is_selected: false,
                diagnosed_need_id: nil,
                content: nil
              }
            ]
          },
          {
            category: nil,
            questions: [
              {
                question_id: nil,
                label: diagnosed_need2.question_label,
                is_selected: true,
                diagnosed_need_id: diagnosed_need2.id,
                content: 'Pas Content'
              }
            ]
          }
        ]
      end

      it { is_expected.to eq expected_array }
    end
  end
end
