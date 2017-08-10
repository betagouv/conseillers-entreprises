# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateDiagnosis do
  describe 'clean_params' do
    subject(:cleaned_params) { described_class.clean_update_params params, current_step: current_step }

    let(:current_step) { 2 }

    context 'regular case as an integer' do
      let(:params) { { content: 'content', step: 3 } }

      it('returns params without the keys that are blanks') do
        expect(cleaned_params).to eq content: 'content', step: 3
      end
    end

    context 'regular case as a string' do
      let(:params) { { content: 'content', step: '3' } }

      it('returns params without the step key') do
        expect(cleaned_params).to eq content: 'content', step: 3
      end
    end

    context 'content is blank' do
      let(:params) { { content: '', step: 3 } }

      it('returns params without the keys that are blanks') do
        expect(cleaned_params).to eq step: 3
      end
    end

    context 'the step is smaller than current step' do
      let(:params) { { content: 'content', step: 1 } }

      it('returns params without the step key') do
        expect(cleaned_params).to eq content: 'content'
      end
    end

    context 'the step is a string beginning with an integer' do
      let(:params) { { content: 'content', step: '5abcd' } }

      it('returns params without the step key') do
        expect(cleaned_params).to eq content: 'content', step: 5
      end
    end
  end
end
