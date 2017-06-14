# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to have_many :answers }
  it { is_expected.to have_many :assistances }
  it { is_expected.to belong_to :answer }
  it { is_expected.to belong_to :category }

  describe 'scopes' do
    describe 'without_answer_parent' do
      let(:question_without_parent) { create :question }
      let(:answer) { create :answer, parent_question: question_without_parent }
      let(:question_with_parent) { create :question, answer: answer }

      it { expect(Question.without_answer_parent).to eq [question_without_parent] }
    end
  end
end
