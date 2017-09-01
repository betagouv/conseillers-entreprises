# frozen_string_literal: true

json.array! @diagnosed_needs do |diagnosed_need|
  json.partial! 'api/diagnosed_needs/diagnosed_need', diagnosed_need: diagnosed_need
end
