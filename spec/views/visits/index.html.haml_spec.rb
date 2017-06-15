# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'visits/index.html.haml', type: :view do
  before do
    visit = create :visit
    assign :visits, [visit]
    render
  end

  it('displays a title') { expect(rendered).to match(/Visites/) }
end
