require 'rails_helper'

describe RecordExtensions::CreatedWithin do
  describe 'scopes' do
    describe 'created_last_week' do
      it do
        new_record = create :user
        create :user, created_at: 2.weeks.ago

        expect(User.created_last_week).to contain_exactly(new_record)
      end
    end

    describe 'created_before_last_week' do
      it do
        create :user
        old_record = create :user, created_at: 2.weeks.ago

        expect(User.created_before_last_week).to contain_exactly(old_record)
      end
    end

    describe 'updated_last_week' do
      it do
        new_record = create :user
        create :user, updated_at: 2.weeks.ago

        expect(User.updated_last_week).to contain_exactly(new_record)
      end
    end

    describe 'updated_yesterday' do
      it do
        new_record = create :user
        create :user, updated_at: 2.days.ago

        expect(User.updated_yesterday).to contain_exactly(new_record)
      end
    end
  end
end
