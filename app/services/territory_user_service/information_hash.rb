# frozen_string_literal: true

module TerritoryUserService
  class InformationHash < Hash
    def fill_created_diagnoses_statistics(created_diagnoses)
      self[:created_diagnoses] = {}
      self[:created_diagnoses][:count] = created_diagnoses.count
      self[:created_diagnoses][:items] = created_diagnoses
    end

    def fill_updated_diagnoses_statistics(updated_diagnoses)
      self[:updated_diagnoses] = {}
      self[:updated_diagnoses][:count] = updated_diagnoses.count
      self[:updated_diagnoses][:items] = updated_diagnoses
    end

    def fill_completed_diagnoses_statistics(completed_diagnoses)
      self[:completed_diagnoses] = {}
      self[:completed_diagnoses][:count] = completed_diagnoses.count
      self[:completed_diagnoses][:items] = completed_diagnoses
    end

    def fill_contacted_experts_count_statistics(contacted_experts_count)
      self[:contacted_experts_count] = contacted_experts_count
    end
  end
end
