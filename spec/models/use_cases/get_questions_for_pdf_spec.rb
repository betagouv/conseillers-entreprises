# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetQuestionsForPdf do
  describe 'perform' do
    subject { described_class.perform }

    let(:category1) { create :category }
    let(:category2) { create :category }

    let(:institution1) { create :institution }
    let(:institution2) { create :institution }

    let(:expert1) { create :expert, institution: institution1 }
    let(:expert2) { create :expert, institution: institution2 }

    let(:assistance1) { create :assistance, question: question1 }
    let(:assistance2) { create :assistance, question: question1 }

    let(:question1) { create :question, category: category1 }
    let(:question2) { create :question, category: category1 }
    let(:question3) { create :question, category: category2 }

    before do
      create :assistance_expert, assistance: assistance1, expert: expert1
      create :assistance_expert, assistance: assistance2, expert: expert2
    end

    context 'no diagnosed_need' do
      let!(:expected_array) do
        [
          {
            category: category1.label,
                    questions: [
                      {
                        label: question1.label,
                        institutions_list: "#{institution1.name}, #{institution2.name}"
                      },
                      {
                        label: question2.label,
                        institutions_list: ''
                      }
                    ]
          },
          {
            category: category2.label,
            questions: [
              {
                label: question3.label,
                institutions_list: ''
              }
            ]
          }
        ]
      end

      it { is_expected.to match_array expected_array }
    end
  end
end
