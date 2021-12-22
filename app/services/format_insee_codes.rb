# frozen_string_literal: true

class FormatInseeCodes
  # Accepts string of INSEE codes separated by spaces
  def self.normalize(codes)
    codes.split.map { |code| code.length == 4 ? code.prepend('0') : code }.join(' ')
  end
end
