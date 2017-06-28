# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateDiagnosis do
  describe 'create_for_params' do
    let(:visit) { create :visit, id: 4 }

    context 'no selected need' do
      let(:params) { { 'visit_id' => visit.id.to_s } }

      before { described_class.create_with_params params }

      it 'creates a diagnosis linked to the right visit' do
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.first.visit).to eq visit
      end
    end

    context 'one selected need with no selected key' do
      let(:question) { create :question }
      let(:params) do
        {
          'visit_id' => visit.id.to_s,
          'diagnosed_needs' => [
            {
              'question_label' => question.label,
              'question_id' => question.id.to_s
            }
          ]
        }
      end

      before { described_class.create_with_params params }

      it 'creates a diagnosis linked to the right visit' do
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.first.visit).to eq visit
      end

      it 'does not create a diagnosed_need' do
        expect(DiagnosedNeed.all.count).to eq 0
      end
    end

    context 'one selected need with selected = on' do
      let(:question) { create :question }
      let(:params) do
        {
          'visit_id' => visit.id.to_s,
          'diagnosed_needs' => [
            {
              'question_label' => question.label,
              'question_id' => question.id.to_s,
              'selected' => 'on'
            }
          ]
        }
      end

      before { described_class.create_with_params params }

      it 'creates a diagnosis linked to the right visit' do
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.last.visit).to eq visit
      end

      it 'creates a diagnosed_need linked to the right diagnosis and right question' do
        expect(DiagnosedNeed.all.count).to eq 1
        expect(DiagnosedNeed.last.diagnosis).to eq Diagnosis.first
        expect(DiagnosedNeed.last.question).to eq question
        expect(DiagnosedNeed.last.question_label).to eq question.label
      end
    end

    context 'multiple selected needs' do
      let(:question1) { create :question }
      let(:question2) { create :question }
      let(:params) do
        {
          'visit_id' => visit.id.to_s,
          'diagnosed_needs' => [
            {
              'question_label' => question1.label,
              'question_id' => question1.id.to_s,
              'selected' => 'on'
            },
            {
              'question_label' => question2.label,
              'question_id' => question2.id.to_s,
              'selected' => 'on'
            }
          ]
        }
      end

      before { described_class.create_with_params params }

      it 'creates a diagnosis linked to the right visit' do
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.last.visit).to eq visit
      end

      it 'creates multiple diagnosed_needs' do
        expect(DiagnosedNeed.all.count).to eq 2
      end
    end
  end
end
