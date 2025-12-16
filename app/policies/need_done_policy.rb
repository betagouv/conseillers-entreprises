class NeedDonePolicy < NeedPolicy
  class Scope < NeedPolicy::Scope
    def resolve
      if user.is_admin?
        super.diagnosis_completed.done
      else
        super.merge(Match.done).distinct
      end
    end
  end
end
