module DuplicateUser
  def duplicate_from(old_user, params)
    self.transaction do
      new_user = new(params)
      new_user.antenne = old_user.antenne
      new_user.save!

      # single-user expert
      old_single_user_expert = old_user.single_user_experts.first
      if old_single_user_expert.present?
        new_single_user_expert = new_user.create_single_user_experts
        # territorial zones
        if old_single_user_expert.territorial_zones.any?
          db_attributes = old_single_user_expert.territorial_zones.map{ it.attributes.except("id", "created_at", "updated_at") }
          new_single_user_expert.territorial_zones.insert_all(db_attributes)
        end
        # match filters
        if old_single_user_expert.match_filters.any?
          db_attributes = old_single_user_expert.match_filters.map{ it.attributes.except("id", "created_at", "updated_at") }
          new_single_user_expert.match_filters.insert_all(db_attributes)
        end
      end

      # teams
      new_user.experts << old_user.experts.with_many_users

      # user rights
      db_attributes = old_user.user_rights.map{ it.attributes.except("id", "created_at", "updated_at") }
      new_user.user_rights.insert_all(db_attributes)

      new_user
    end
  end
end
