# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'diagnosis/index.html.haml', type: :view do
  let(:question) { create :question }
  let!(:answer) { create :answer, question: question }

  before { assign :questions, [question] }

  it 'displays a title' do
    render
    expect(rendered).to match(/Diagnostic/)
  end

  it 'displays two list elements' do
    render
    assert_select 'li', count: 2
  end
end
