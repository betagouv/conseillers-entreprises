class UserPolicy < ApplicationPolicy
  # TODO mettre admin? ici aussi
  def manager?
    @user.is_manager?
  end
end
