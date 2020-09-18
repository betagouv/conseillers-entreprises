module NestedErrorsHelper
  def nested_errors_messages(object, level = 0)
    errors = object.errors
    return if errors.empty?

    main_message = errors.full_messages.to_sentence || object.to_s
    main_message = '• ' * level + main_message

    sub_messages = errors.details.values.flatten.flat_map do |hash|
      case value = hash[:value]
      when ActiveRecord::Base
        nested_errors_messages(value.errors, level + 1)
      when ActiveRecord::Relation
        value.map { |object| nested_errors_messages(object, level + 1) }
      else nil
      end
    end
      .compact

    [main_message, sub_messages].flatten.join("\n")
  end
end
