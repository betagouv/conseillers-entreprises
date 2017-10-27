# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

module UserMailerHelper
  def text_key_for_status(old_status, current_status)
    case [old_status, current_status]
    when %w[taking_care quo], %w[done quo], %w[not_for_me quo]
      'waiting_for_answer'
    when %w[quo taking_care]
      'taking_care'
    when %w[not_for_me taking_care], %w[done taking_care]
      'not_finished'
    when %w[quo done], %w[taking_care done], %w[not_for_me done]
      'done'
    when %w[quo not_for_me], %w[taking_care not_for_me], %w[done not_for_me]
      'not_for_me'
    end
  end
end

# rubocop:enable Metrics/MethodLength
