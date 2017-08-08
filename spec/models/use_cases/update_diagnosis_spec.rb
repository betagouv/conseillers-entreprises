# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateDiagnosis do
  describe 'clean_params' do
    subject(:cleaning) { described_class.clean_update_params params, current_step: current_step }

    let(:current_step) { 2 }

    context 'some of the keys are nil or empty' do
      let(:params) { { content: 'content', step: nil } }

      it('returns params without the keys that are blanks') do
        cleaned_params = { content: 'content' }
        expect(cleaning).to eq cleaned_params
      end
    end

    context 'the step is not a string' do
      let(:params) { { content: 'content', step: 'string' } }

      it('returns params without the step key') do
        cleaned_params = { content: 'content' }
        expect(cleaning).to eq cleaned_params
      end
    end

    context 'the step is smaller than current step' do
      let(:params) { { content: 'content', step: 1 } }

      it('returns params without the step key') do
        cleaned_params = { content: 'content' }
        expect(cleaning).to eq cleaned_params
      end
    end

    context 'the step is greater than 5' do
      let(:params) { { content: 'content', step: 6 } }

      it('returns params without the step key') do
        cleaned_params = { content: 'content' }
        expect(cleaning).to eq cleaned_params
      end
    end
  end
end
