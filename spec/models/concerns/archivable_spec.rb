# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archivable do
  describe 'scopes' do
    describe 'archive' do
      let(:match) { create :match }

      before do
        match.archive!
      end

      it('archives the match') do
        expect(match.is_archived).to be_truthy
        expect(Match.count).to eq 1
        expect(Match.archived(false).count).to eq 0
        expect(Match.archived(true).count).to eq 1
      end
    end
  end
end
