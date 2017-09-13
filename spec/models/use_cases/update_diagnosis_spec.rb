# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateDiagnosis do
  describe 'clean_params' do
    subject(:cleaned_params) { described_class.clean_update_params params, current_step: current_step }

    let(:current_step) { 2 }

    context 'regular case as an integer' do
      let(:params) { { content: 'content', step: 3 } }

      it('returns params without modifications') do
        hash = { content: 'content', step: 3 }
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq true
        expect(cleaned_params.key?(:step)).to eq true
      end
    end

    context 'regular case as a string' do
      let(:params) { { content: 'content', step: '3' } }

      it('returns params without modifications') do
        hash = { content: 'content', step: 3 }
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq true
        expect(cleaned_params.key?(:step)).to eq true
      end
    end

    context 'content is blank and there is no step' do
      let(:params) { { content: '' } }

      it('returns an empty hash') do
        hash = {}
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq false
        expect(cleaned_params.key?(:step)).to eq false
      end
    end

    context 'the step is smaller than current step' do
      let(:params) { { content: 'content' } }

      it('returns params without the step key') do
        hash = { content: 'content' }
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq true
        expect(cleaned_params.key?(:step)).to eq false
      end
    end

    context 'there is no step and content is not blank' do
      let(:params) { { content: 'content' } }

      it('returns params without the step key') do
        hash = { content: 'content' }
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq true
        expect(cleaned_params.key?(:step)).to eq false
      end
    end

    context 'the step is smaller than current step' do
      let(:current_step) { 5 }
      let(:params) { { 'step' => 3 } }

      it('returns empty params') do
        hash = {}
        expect(cleaned_params).to eq hash

        expect(cleaned_params.key?(:content)).to eq false
        expect(cleaned_params.key?(:step)).to eq false
        expect(cleaned_params.key?('step')).to eq false
      end
    end
  end
end
