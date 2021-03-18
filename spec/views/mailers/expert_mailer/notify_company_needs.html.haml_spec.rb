# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs.html.haml', type: :view do
  context 'hash with several information' do
    let(:contact) { create :contact, :with_email }
    let(:user) { create :user }
    let(:expert) { create :expert }
    let(:need1) { create(:need, matches: [create(:match, expert: expert)]) }
    let(:need2) { create(:need, matches: [create(:match, expert: expert)]) }

    before do
      assign(:expert, expert)
      assign(:diagnosis, diagnosis)

      render
    end

    context 'when diagnosis has a date and there are two subjects' do
      let(:diagnosis) { create :diagnosis, advisor: user, visitee: contact, needs: [need1, need2] }

      it 'displays the date, phone number and 2 list items' do
        expect(rendered).to include "analyses/#{diagnosis.id}"
        assert_select 'h2.subject', count: 2
      end
    end

    context 'when there is one subject' do
      let(:diagnosis) { create :diagnosis, advisor: user, visitee: contact, needs: [need1] }

      it 'does not display the date, but displays email and one list item' do
        expect(rendered).to include "analyses/#{diagnosis.id}"
        assert_select 'h2.subject', count: 1
      end
    end
  end
end
