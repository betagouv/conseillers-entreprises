# frozen_string_literal: true

module ControllerMacros
  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end
end
