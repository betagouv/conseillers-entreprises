class NeedInProgressPolicy < NeedPolicy
  class Scope < NeedPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.in_progress
      else
        scope.received_by(user).joins(:matches).merge(Match.in_progress.where(expert: user.experts)).distinct
      end
    end
  end
end
