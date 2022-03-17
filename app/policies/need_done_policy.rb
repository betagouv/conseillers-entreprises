class NeedDonePolicy < NeedPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.done
      else
        scope.received_by(user).select { |n| n.matches.done.find_by(expert: user.experts) }
      end
    end
  end
end
