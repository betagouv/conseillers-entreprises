class CheckPasswordComplexity
  attr_reader :password

  MAX_MISSING_ELEMENTS = 1

  REGEXES = {
    uppercase: /[A-Z]/,
    downcase: /[a-z]/,
    digit: /\d/,
    special: /\W/
  }

  def initialize(password)
    @password = password
  end

  def valid?
    @missing_elements = CheckPasswordComplexity::REGEXES.keys.each_with_object([]) do |key, array|
      array.push(key) unless present?(key)
    end
    return true if @missing_elements.size <= MAX_MISSING_ELEMENTS
    false
  end

  def error_message
    return if valid?
    count = @missing_elements.size - MAX_MISSING_ELEMENTS
    missing_elements_to_s = human_missing_elements(@missing_elements)

    I18n.t('password.missing_complexity_elements', elements: missing_elements_to_s, count: count)
  end

  private

  def present?(key)
    password.match(regex(key))
  end

  def regex(key)
    REGEXES[key]
  end

  def human_missing_elements(missing_elements)
    missing_elements
      .map{ |e| I18n.t(e, scope: [:password, :missing_elements]) }
      .to_sentence(two_words_connector: or_connector, last_word_connector: or_connector)
  end

  def or_connector
    I18n.t('or_connector')
  end
end
