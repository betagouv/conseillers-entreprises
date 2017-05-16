# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to have_many :answers }
  it { is_expected.to belong_to :answer }

  describe 'scopes' do
    describe 'without_anwser_parent' do
      let(:question_without_parent) { create :question }
      let(:answer) { create :answer, question: question_without_parent }
      let!(:question_with_parent) { create :question, answer: answer }
      
      it { expect(Question.without_anwser_parent).to eq [question_without_parent] }
    end
  end
end
