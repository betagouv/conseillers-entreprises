class FeedbackPolicy < ApplicationPolicy
  def destroy?
    if user.present?
      admin? ||
        creator? ||
        @record.expert.in?(user.experts)
    else
      creator?
    end
  end

  def creator?
    if user.present?
      @record.user == user
    else
      @record.expert == user
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
