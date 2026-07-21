class ActivityReportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin? || @user&.is_manager? || @user&.is_sponsor?
  end

  def stats?
    @user&.is_admin? || in_supervised_antennes?(@record.antenne) || in_sponsored_institutions?(@record.antenne.institution)
  end

  def matches?
    @user&.is_admin? || in_supervised_antennes?(@record.antenne)
  end

  private

  def in_supervised_antennes?(antenne)
    @user&.supervised_antennes&.include?(antenne)
  end

  def in_sponsored_institutions?(institution)
    @user&.sponsored_institutions&.include?(institution)
  end
end
