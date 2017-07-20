# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.haml', type: :view do
  it 'displays a title' do
    render

    expect(rendered).to match(/Un outil pour conseiller les entreprises/)
  end
end
