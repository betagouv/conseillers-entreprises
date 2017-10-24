# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

module UserMailerHelper
  def text_key_for_step(old_step, current_step)
    case [old_step, current_step]
    when %w[taking_care quo], %w[done quo], %w[not_for_me quo]
      return '.waiting_for_answer'
    when %w[quo taking_care]
      '.taking_care'
    when %w[not_for_me taking_care], %w[done taking_care]
      return '.not_finished'
    when %w[quo done], %w[taking_care done], %w[not_for_me done]
      return '.done'
    when %w[quo not_for_me], %w[taking_care not_for_me], %w[done not_for_me]
      return '.not_for_me'
    end
  end
end

# rubocop:enable Metrics/MethodLength
