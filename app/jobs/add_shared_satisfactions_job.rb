class AddSharedSatisfactionsJob < ApplicationJob
  queue_as :low_priority

  def perform(user_id)
    manager = User.find(user_id)
    return unless manager

    manager.managed_antennes.find_each do |antenne|
      not_yet_shared_ids = antenne
        .perimeter_received_shared_company_satisfactions
        .pluck(:id) - manager.shared_company_satisfactions.pluck(:id)
      CompanySatisfaction.where(id: not_yet_shared_ids).find_each do |company_satisfaction|
        expert = company_satisfaction.done_experts.where(antenne_id: manager.supervised_antennes.ids).first
        company_satisfaction.shared_satisfactions.where(user: manager).first_or_create(expert: expert)
      end
    end
  end
end
