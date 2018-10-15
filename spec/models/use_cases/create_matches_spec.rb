# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateMatches do
  describe 'perform' do
    let(:diagnosis) { create :diagnosis }
    let(:question) { create :question }
    let(:assistance) { create :assistance, question: question }
    let(:assistance_expert) { create :assistance_expert, assistance: assistance }
    let!(:diagnosed_need) { create :diagnosed_need, question: question, diagnosis: diagnosis }

    let(:assistance_expert_ids) { [assistance_expert.id] }

    context 'one match' do
      before { described_class.perform(diagnosis, assistance_expert_ids) }

      it do
        expect(Match.first.diagnosed_need).to eq diagnosed_need
        expect(Match.first.assistance_expert).to eq assistance_expert
        expect(Match.first.relay).to be_nil
        expect(Match.first.assistance_title).to eq assistance_expert.assistance.title
        expect(Match.first.expert_full_name).to eq assistance_expert.expert.full_name
        expect(Match.first.expert_institution_name).to eq assistance_expert.expert.local_office.name
      end
    end
  end
end
