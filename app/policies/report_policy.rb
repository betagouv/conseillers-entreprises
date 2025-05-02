class ReportPolicy < ApplicationPolicy
  def index?
    indexes_policy?
  end

  def stats?
    indexes_policy?
  end

  def matches?
    indexes_policy?
  end

  def show_navbar?
    @user&.is_manager?
  end

  def download?
    @user.is_admin? || in_supervised_antennes?(@record.reportable) || @record.reportable.managers.include?(@user)
  end

  private

  def in_supervised_antennes?(reportable)
    reportable.is_a?(Antenne) &&
    (@user.is_manager? && @user&.supervised_antennes&.include?(reportable))
  end

  def indexes_policy?
    @user&.is_admin? || in_supervised_antennes?(@record)
  end
end
