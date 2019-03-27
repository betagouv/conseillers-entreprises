# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:matches).dependent(:nullify)
      is_expected.to belong_to :assistance
      is_expected.to belong_to :expert
    end
  end

  describe 'scopes' do
    describe 'relevant_for' do
      subject(:assistance_experts) { AssistanceExpert.relevant_for(diagnosed_need) }

      let(:diagnosed_need) do
        create :diagnosed_need,
          question: create(:question),
          diagnosis: create(:diagnosis, facility: create(:facility, commune: create(:commune)))
      end

      let(:relevant_assistance) { create(:assistance, question: diagnosed_need.question) }
      let(:unrelated_assistance) { create :assistance, question: create(:question) }

      let(:local_expert1) { create :expert, communes: [diagnosed_need.facility.commune] }
      let(:local_expert2) { create :expert, communes: [diagnosed_need.facility.commune] }
      let(:faraway_expert) { create :expert, communes: [create(:commune)] }

      let(:local_relevant_ae) { create :assistance_expert, expert: local_expert1, assistance: relevant_assistance }

      before do
        # local_unrelated
        create :assistance_expert, expert: local_expert2, assistance: unrelated_assistance
        # faraway
        create :assistance_expert, expert: faraway_expert, assistance: relevant_assistance
      end

      it { is_expected.to eq [local_relevant_ae] }
    end
  end
end
