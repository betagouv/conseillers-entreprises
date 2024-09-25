class AntennePolicy < ApplicationPolicy
  def show_manager?
    admin?
  end

  def show?
    @user.antenne == @record || @user.managed_antennes.include?(@record)
  end
end
