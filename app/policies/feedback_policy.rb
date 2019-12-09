class FeedbackPolicy < ApplicationPolicy
  def destroy?
    admin? || creator? || @user.experts.pluck(:id).include?(@record.expert_id)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
