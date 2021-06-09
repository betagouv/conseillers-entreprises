# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs.html.haml', type: :view do
  context 'hash with several information' do
    let(:contact) { create :contact, :with_email }
    let(:user) { create :user }
    let(:expert) { create :expert }
    let(:need) { create(:need, matches: [create(:match, expert: expert)]) }

    before do
      assign(:expert, expert)
      assign(:diagnosis, need.diagnosis)
      assign(:need, need)

      render
    end

    it 'displays the date, phone number and 1 items' do
      expect(rendered).to include "besoins/#{need.id}"
      assert_select 'h1', count: 1
    end
  end
end
