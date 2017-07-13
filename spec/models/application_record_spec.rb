# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'scopes' do
    describe 'created_last_week' do
      it do
        new_record = create :user
        create :user, created_at: 2.weeks.ago
        expect(User.created_last_week).to eq [new_record]
      end
    end
  end
end
