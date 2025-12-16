class NeedDonePolicy < NeedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.done
      else
        scope.received_by(user).joins(:matches).merge(Match.done.where(expert: user.experts)).distinct
      end
    end
  end
end
