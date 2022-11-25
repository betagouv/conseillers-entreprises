# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archivable do
  describe 'scopes' do
    describe 'archive' do
      let(:diagnosis) { create :diagnosis }

      before do
        diagnosis.archive!
      end

      it('archives the diagnosis') do
        expect(diagnosis.is_archived).to be_truthy
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.archived(false).count).to eq 0
        expect(Diagnosis.archived(true).count).to eq 1
      end
    end
  end
end
