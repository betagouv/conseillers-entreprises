# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :created_last_week, (-> { where("#{table_name}.created_at >= ?", 1.week.ago) })
  scope :updated_last_week, (-> { where("#{table_name}.updated_at >= ?", 1.week.ago) })
end
