# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.haml', type: :view do
  describe 'hero button' do
    context 'user is logged in' do
      login_user

      it 'displays a title' do
        render

        expect(rendered).to include 'Commencez !'
      end
    end

    context 'user is not logged in' do
      it 'displays a title' do
        render

        expect(rendered).to include 'Inscrivez-vous !'
      end
    end
  end
end
