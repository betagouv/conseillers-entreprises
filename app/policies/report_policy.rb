class ReportPolicy < ApplicationPolicy
  def index?
    @user&.role_antenne_manager?
  end

  def download_matches?
    @user&.role_antenne_manager? && @record.antenne == @user.antenne
  end
end
