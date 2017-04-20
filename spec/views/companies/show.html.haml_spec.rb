# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/show.html.haml', type: :view do
  let(:company) { create :company }

  before { assign :company, company }

  it 'does not render a list of weekly_must_read_emails' do
    render
    assert_select 'h1', text: company.name, count: 1
    assert_select 'tr>td', text: 'Siren', count: 1
    assert_select 'tr>td', text: company.siren, count: 1
  end
end
