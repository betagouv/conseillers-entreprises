class ReportPolicy < ApplicationPolicy
  def index?
    @user&.is_manager?
  end

  def download?
    @user.managed_antennes.include?(@record.antenne)
  end
end
