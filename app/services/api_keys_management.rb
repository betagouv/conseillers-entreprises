class ApiKeysManagement
  def self.batch_revoke
    ApiKey.active.where(ApiKey.arel_table[:created_at].lt(ApiKey::LIFETIME.ago)).each do |key|
      key.revoke
    end
  end
end
