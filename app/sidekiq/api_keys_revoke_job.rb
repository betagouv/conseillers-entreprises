class ApiKeysRevokeJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    ApiKey.active.where(ApiKey.arel_table[:created_at].lt(ApiKey::LIFETIME.ago)).find_each do |key|
      key.revoke
    end
  end
end