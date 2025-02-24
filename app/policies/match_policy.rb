class MatchPolicy < ApplicationPolicy
  def update?
    admin? || @record.contacted_users.include?(@user) || in_supervised_antennes?
  end

  def update_status?
    admin? || in_supervised_antennes?
  end

  def show_info?
    admin?
  end

  def show_inbox?
    admin?
  end

  private

  def in_supervised_antennes?
    (@user.is_manager? && @user.supervised_antennes.include?(@record.expert.antenne))
  end
end
