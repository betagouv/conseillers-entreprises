class ReportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? || @user&.is_manager?
  end

  def stats?
    @user&.is_admin? || in_supervised_antennes?(@record)
  end

  def matches? = stats?

  def download?
    @user.is_admin? || in_supervised_antennes?(@record.reportable)
  end

  private

  def in_supervised_antennes?(reportable)
    reportable.is_a?(Antenne) && @user&.supervised_antennes&.include?(reportable)
  end
end
