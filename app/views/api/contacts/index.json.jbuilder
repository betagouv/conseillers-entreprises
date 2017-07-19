# frozen_string_literal: true

json.array! @contacts do |contact|
  json.partial! 'api/contacts/contact', contact: contact
end
