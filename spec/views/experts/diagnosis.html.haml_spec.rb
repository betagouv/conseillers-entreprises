# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'experts/diagnosis.html.haml', type: :view do
  let(:visit) { create :visit, :with_visitee }
  let(:diagnosis) { create :diagnosis, visit: visit }
  let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
  let!(:match) do
    create :match,
           :with_assistance_expert,
           diagnosed_need: diagnosed_need,
           assistance_title: 'Help companies in distress'
  end

  before do
    assign :diagnosis, diagnosis
    assign :current_user_diagnosed_needs, [diagnosed_need]
  end

  context 'experts still exists' do
    it do
      render

      expect(rendered).to include 'Institution'
      expect(rendered).to include 'Champ de compétence'
    end
  end

  context 'experts does not exist any more' do
    before { match.assistance_expert.destroy }

    it do
      render

      expect(rendered).to include 'Institution'
      expect(rendered).to include 'Champ de compétence'
    end
  end
end
