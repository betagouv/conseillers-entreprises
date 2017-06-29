# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosedNeed, type: :model do
  it do
    is_expected.to belong_to :diagnosis
    is_expected.to belong_to :question
    is_expected.to validate_presence_of(:diagnosis)
  end

  describe 'assistances' do
    let(:assistance_for_maubeuge) { create :assistance, for_maubeuge: true }
    let(:assistance_for_elsewhere) { create :assistance, for_maubeuge: false }

    context 'no question' do
      let(:diagnosed_need) { create :diagnosed_need, question: nil }

      it 'has no assistance' do
        expect(diagnosed_need.assistances.count).to eq 0
      end
    end
    context 'a visit in maubeuge' do
      let(:facility) { create :facility, city_code: 59_003 }
      let(:visit) { create :visit, facility: facility }
      let(:diagnosis) { create :diagnosis, visit: visit }
      let(:diagnosed_need) { create :diagnosed_need, question: question }

      context 'a question with two assistances with one for maubeuge' do
        let(:question) { create :question, assistances: [assistance_for_maubeuge, assistance_for_elsewhere] }

        it 'has one assistance' do
          expect(diagnosed_need.assistances.count).to eq 1
        end
      end
      context 'a question with one assistances not for maubeuge' do
        let(:question) { create :question, assistances: [assistance_for_elsewhere] }

        it 'has one assistance' do
          expect(diagnosed_need.assistances.count).to eq 0
        end
      end
    end
  end
end
