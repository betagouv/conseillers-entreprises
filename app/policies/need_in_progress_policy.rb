class NeedInProgressPolicy < NeedPolicy
  class Scope < NeedPolicy::Scope
    def resolve
      if user.is_admin?
        scope.diagnosis_completed.in_progress.order(created_at: :desc)
      else
        scope.received_by(user).joins(:matches).merge(Match.in_progress.where(expert: user.experts)).distinct.order(created_at: :desc)
      end
    end
  end
end
