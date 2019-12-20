require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :need
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:need)
        is_expected.to validate_presence_of(:description)
      end
    end
  end

  describe 'persons_to_notify' do
    let(:advisor) { create :user }
    let(:expert1) { create :expert }
    let(:expert2) { create :expert }
    let(:matches) { [create(:match, expert: expert1), create(:match, expert: expert2)] }
    let(:need) { create :need, advisor: advisor, matches: matches }
    let(:feedback) { create :feedback, need: need, author: author }

    subject { feedback.persons_to_notify }

    context 'when the author is the one of the contacted experts' do
      let(:author) { expert1 }

      it{ is_expected.to eq [advisor] }
    end

    context 'when the author is the diagnosis advisor' do
      let(:author) { advisor }

      it{ is_expected.to match_array [expert1, expert2] }
    end
  end
end
