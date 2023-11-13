class NeedDonePolicy < NeedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.done.order(created_at: :desc)
      else
        scope.received_by(user).joins(:matches).merge(Match.done.where(expert: user.experts)).distinct.order(created_at: :desc)
      end
    end
  end
end
