require 'rails_helper'

describe RecordExtensions::WithCount do
  describe 'with_count' do
    subject(:query) { User.where(email: "test@test").with_count(:feedbacks) }

    before { create :user, email: "test@test", feedbacks: create_list(:feedback, 4, :for_need) }

    it do
      expect(query.strict_loading.first.feedbacks_count).to eq 4
    end
  end
end
