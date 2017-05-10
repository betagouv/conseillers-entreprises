# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'diagnosis/index.html.haml', type: :view do
  it 'displays a title' do
    render

    expect(rendered).to match(/Diagnosis#index/)
  end
end
