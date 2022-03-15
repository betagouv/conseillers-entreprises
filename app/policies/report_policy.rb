class ReportPolicy < ApplicationPolicy
  def index?
    @user&.role_antenne_manager?
  end

  def download?
    @user&.role_antenne_manager? && @record.antenne == @user.antenne
  end
end
