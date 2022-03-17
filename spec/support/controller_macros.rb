# frozen_string_literal: true

module ControllerMacros
  def login_user
    let(:current_user) { create :user }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in current_user
    end
  end

  def login_admin
    let(:current_user) { create :user, :admin }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in current_user
    end
  end
end
