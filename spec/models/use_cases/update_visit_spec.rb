# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateVisit do
  describe 'validate_happened_on' do
    subject(:validation) { described_class.validate_happened_on happened_on }

    context 'when happened at is valid' do
      let(:happened_on) { '2012-02-12' }

      it('does not throw an error') do
        expect { validation }.not_to raise_error
      end
    end

    context 'when happened at is invalid' do
      let(:happened_on) { '2012/12/Choufleur' }

      it('throws an argument error') do
        expect { validation }.to raise_error ArgumentError
      end
    end

    context 'when happened at is nil' do
      let(:happened_on) { nil }

      it('throws an argument error') do
        expect { validation }.to raise_error ArgumentError
      end
    end
  end
end
