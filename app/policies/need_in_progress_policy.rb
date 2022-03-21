class NeedInProgressPolicy < NeedPolicy
  class Scope < NeedPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.in_progress
      else
        scope.received_by(user).select { |n| n.matches.in_progress.find_by(expert: user.experts) }
      end
    end
  end
end
