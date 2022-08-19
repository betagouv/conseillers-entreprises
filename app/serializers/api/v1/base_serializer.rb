class Api::V1::BaseSerializer < ActiveModel::Serializer
  # {
  #   "data": { ... },
  #   "links": { ... },
  #   "metadata": { ... }
  # }

  # { "errors": [
  #   { "code": "...",
  #   "title": "short",
  #   "detail": "very long",
  #   "source": { "parameter": "query-param" },
  #   "meta": { ... } }
  #   ] }
end
