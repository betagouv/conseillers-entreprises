class FeedbackPolicy < ApplicationPolicy
  def destroy?
    creator?
  end

  def creator?
    @record.user == @user
  end

  def prefill?
    @user.role_admin? && I18n.t("prefill_feedbacks.#{@record.category}").is_a?(Hash)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
