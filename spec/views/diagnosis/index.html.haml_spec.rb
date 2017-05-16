# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'diagnosis/index.html.haml', type: :view do
  let(:question) { create :question }

  before do
    create :answer, parent_question: question
    assign :questions, [question]
    render
  end

  it('displays a title') { expect(rendered).to match(/Diagnostic/) }
  it('displays two list elements') { assert_select 'tr', count: 2 }
end
