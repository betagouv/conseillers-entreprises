# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/index.html.haml', type: :view do
  before do
    visit = create :visit
    allow(view).to receive(:params).and_return(visit_id: visit.id)
  end

  it('displays a title') do
    render
    expect(rendered).to match(/Entreprises/)
  end
end
