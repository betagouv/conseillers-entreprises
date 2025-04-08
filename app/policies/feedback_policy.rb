class FeedbackPolicy < ApplicationPolicy
  def create?
    @record.category_need? || @user.is_admin?
  end

  def destroy?
    creator?
  end

  def creator?
    @record.user == @user
  end

  def prefill?
    @user.is_admin? && I18n.exists?("prefill_feedbacks.#{@record.category}", :fr)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
