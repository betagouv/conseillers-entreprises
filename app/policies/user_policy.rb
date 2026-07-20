class UserPolicy < ApplicationPolicy
  def api_key?
    admin?
  end

  alias reset_api_key? api_key?
end
