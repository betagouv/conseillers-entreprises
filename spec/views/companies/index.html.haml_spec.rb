# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/index.html.haml', type: :view do
  it('displays a title') do
    render
    expect(rendered).to match(/Entreprises/)
  end

  context 'there are past queries' do
    before do
      assign :queries, ['12345678901234']
      render
    end

    it('displays one list elements') { assert_select 'li', count: 1 }
  end

  context 'no past queries' do
    before do
      assign :queries, nil
      render
    end

    it('does not display list element') { assert_select 'li', count: 0 }
  end
end
