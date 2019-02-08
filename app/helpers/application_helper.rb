# frozen_string_literal: true

module ApplicationHelper
  def random_color
    %w[red orange yellow olive green teal blue violet pink].sample
  end

  def models_human_description(objects)
    return if objects.blank?
    klass = objects.first.class
    count = objects.count
    "#{count} #{klass.model_name.human(count: count).downcase}"
  end
end
