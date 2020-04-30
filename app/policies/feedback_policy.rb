class FeedbackPolicy < ApplicationPolicy
  def destroy?
    creator?
  end

  def creator?
    @record.user == @user
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
