module Alternatives
  extend ActiveSupport::Concern

  included {}

  def current_alternative(alternatives)
    forced_alternative = params.delete(:alternative)&.to_sym
    if forced_alternative.present?
      alternative = forced_alternative
    elsif cookies[cookie_name] && alternatives.include?(forced_alternative)
      alternative = cookies[cookie_name]
    else
      alternative = alternatives.sample
      cookies[cookie_name] = {
        value: alternative,
        expires: 1.week,
        path: request.fullpath
      }
    end
    alternative
  end

  def reset_alternative
    cookies.delete cookie_name
  end

  def cookie_name
    "_Reso_alternative_#{controller_name}"
  end
end
