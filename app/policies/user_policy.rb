class UserPolicy < ApplicationPolicy
  def api_key?
    admin? || @user.is_tech?
  end

  alias reset_api_key? api_key?
end
