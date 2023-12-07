# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'manager/needs/index' do
  login_manager
  let(:need) { create :need_with_matches, status: :quo }
  let(:matches) { need.matches }

  let(:assignments) do
    enable_pundit(view, current_user)
    assign(:recipient, current_user.antenne)
    assign(:collection_name, :quo_active)
    assign(:inbox_collections_counts, { :quo_active => 0, :taking_care => 1, :done => 2, :not_for_me => 0, :expired => 1 })
    assign(:needs, [need])
    assign(:themes_and_subjects_collection, { :themes => [] })
    render
  end

  describe 'single managed antennes' do
    before { assignments }

    it('displays antenne name') { expect(rendered).to have_css('h1', text: current_user.antenne.name) }

  end

end
