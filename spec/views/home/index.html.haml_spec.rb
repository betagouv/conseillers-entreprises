# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.haml', type: :view do
  it 'displays a title' do
    render

    expect(rendered).to match(/Un outil dédié aux conseillers d'entreprise des organismes publics/)
  end
end
