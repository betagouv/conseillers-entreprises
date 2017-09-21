# frozen_string_literal: true

task update_sae_statuses: :environment do
  SelectedAssistanceExpert.where(status: nil).update_all status: 0
end
