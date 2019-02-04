# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archivable, type: :model do
  describe 'scopes' do
    describe 'archive' do
      let(:diagnosis) { create :diagnosis }

      before do
        diagnosis.archive!
      end

      it('archives the diagnosis') do
        expect(diagnosis).to be_archived
        expect(Diagnosis.all.count).to eq 1
        expect(Diagnosis.not_archived.count).to eq 0
        expect(Diagnosis.archived.count).to eq 1
      end
    end
  end
end
