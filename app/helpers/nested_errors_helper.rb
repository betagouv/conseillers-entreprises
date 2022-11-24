module NestedErrorsHelper
  # :nested_errors_messages
  # Build a full error message for an ActiveRecord object and its relations
  # It works best when using validates_associated.
  # In that case, object.errors contains the associated object,
  # e.g. in the case of user.experts with errors
  # $ user.errors.details
  # =>
  # {
  #   experts: [
  #     {
  #       error: :invalid,
  #       value: [#<Expert>] # <- We can recurse into the Expert object errors.
  #     }
  #   ]
  # }
  #
  # Note: this is primarily used for csv_import.
  def nested_errors_messages(object, level = 0)
    errors = object.errors
    return if errors.empty?

    return if level > 3 # safety net: relationships may indefinitely nest errors

    main_message = errors.full_messages.uniq.to_sentence || object.to_s
    main_message = ('• ' * level) + main_message + "\n"

    sub_messages = errors.details.values.flatten.flat_map do |hash|
      case value = hash[:value]
      when ActiveRecord::Base
        nested_errors_messages(value, level + 1)
      when ActiveRecord::Relation
        value.map { |object| nested_errors_messages(object, level + 1) }
      end
    end
      .compact

    [main_message, sub_messages].flatten.join
  end
end
