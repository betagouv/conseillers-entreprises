# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs.html.haml', type: :view do
  context 'hash with several information' do
    let(:contact) { create :contact, :with_email }
    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee, advisor: user, visitee: contact }
    let(:expert) { create :expert }
    let(:need1) { create(:diagnosed_need, matches: [create(:match, assistance_expert: create(:assistance_expert, expert: expert))]) }
    let(:need2) { create(:diagnosed_need, matches: [create(:match, assistance_expert: create(:assistance_expert, expert: expert))]) }

    before do
      assign(:person, expert)
      assign(:diagnosis, diagnosis)
    end

    context 'when visit has a date, there is an access token and there are two questions' do
      let(:diagnosis) { create :diagnosis, visit: visit, diagnosed_needs: [need1, need2] }

      before do
        assign(:access_token, 'random_access_token')
        render
      end

      it 'displays the date, phone number and 2 list items' do
        expect(rendered).to include "besoins/#{diagnosis.id}?access_token=random_access_token"
        assert_select 'h3.question_label', count: 2
      end
    end

    context 'when there is no access token and there is one question' do
      let(:diagnosis) { create :diagnosis, visit: visit, diagnosed_needs: [need1] }

      before do
        assign(:access_token, nil)
        render
      end

      it 'does not display the date, but displays email and one list item' do
        expect(rendered).to include "besoins/#{diagnosis.id}"
        assert_select 'h3.question_label', count: 1
      end
    end
  end
end
