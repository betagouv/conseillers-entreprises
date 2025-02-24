class ReportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? || in_supervised_antennes?(@record)
  end

  def show_navbar?
    @user&.is_manager?
  end

  def download?
    @user&.is_admin? || in_supervised_antennes?(@record.antenne)
  end

  private

  def in_supervised_antennes?(antenne)
    (@user&.is_manager? && @user&.supervised_antennes&.include?(antenne))
  end
end
