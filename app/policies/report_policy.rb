class ReportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? ||
      (@user&.is_manager? && @user.managed_antennes.include?(@record))
  end

  def show_navbar?
    @user&.is_manager?
  end

  def download?
    @user&.is_admin? || @user.managed_antennes.include?(@record.antenne)
  end
end
