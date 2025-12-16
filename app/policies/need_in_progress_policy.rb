class NeedInProgressPolicy < NeedPolicy
  class Scope < NeedPolicy::Scope
    def resolve
      if user.is_admin?
        super.diagnosis_completed.in_progress
      else
        super.merge(Match.in_progress).distinct
      end
    end
  end
end
