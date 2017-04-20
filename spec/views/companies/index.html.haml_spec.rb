# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/index.html.haml', type: :view do
  it 'displays a title' do
    render

    expect(rendered).to match(/Companies#index/)
  end
end
