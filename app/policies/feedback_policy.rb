class FeedbackPolicy < ApplicationPolicy
  def destroy?
    admin? || creator?
  end

  def creator?
    @record.user == @user || @record.expert.in?(@user.experts)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
