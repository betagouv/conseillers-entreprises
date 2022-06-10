class FeedbackPolicy < ApplicationPolicy
  def create?
    if @record.category_need?
      true
    else
      @user.is_admin?
    end
  end

  def destroy?
    creator?
  end

  def creator?
    @record.user == @user
  end

  def prefill?
    @user.is_admin? && I18n.t("prefill_feedbacks.#{@record.category}").is_a?(Hash)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
