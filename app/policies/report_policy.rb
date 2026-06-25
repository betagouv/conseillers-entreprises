class ReportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? || in_supervised_antennes?(@record) || @user&.is_manager? || @user&.is_sponsor?
  end

  def stats?
    @user&.is_admin? || in_supervised_antennes?(@record) || in_sponsored_institutions?(@record)
  end

  def matches?
    @user&.is_admin? || in_supervised_antennes?(@record)
  end

  def download?
    @user.is_admin? || in_supervised_antennes?(@record.reportable)
  end

  private

  def in_supervised_antennes?(reportable)
    reportable.is_a?(Antenne) && @user&.supervised_antennes&.include?(reportable)
  end

  def in_sponsored_institutions?(reportable)
    reportable.is_a?(Antenne) && @user&.sponsored_institutions&.include?(reportable.institution)
  end
end
