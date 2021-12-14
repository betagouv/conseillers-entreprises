class ReportPolicy < ApplicationPolicy
  def index?
    @user&.role_antenne_manager?
  end
end
