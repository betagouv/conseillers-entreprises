# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/about.html.haml', type: :view do
  it 'displays a title' do
    render

    expect(rendered).to match(/Des entrepreneurs isolés, des conseils cloisonnés/)
  end
end
