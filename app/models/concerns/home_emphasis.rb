module HomeEmphasis
  # Used in Landing and LandingSubject.
  # These classes have two needed attributes:
  # :emphasis and :home_description

  extend ActiveSupport::Concern

  included do
    before_save :set_unique_emphasis_item
  end

  EMPHASIS_CLASSES = [Landing, LandingSubject]

  def set_unique_emphasis_item
    if emphasis
      EMPHASIS_CLASSES.each do |klass|
        if self.is_a? klass
          klass.where.not(id: id).update_all(emphasis: false)
        else
          klass.update_all(emphasis: false)
        end
      end
    end
  end

  def home_emphasis_item
    EMPHASIS_CLASSES.each do |klass|
      found = klass.find_by(emphasis: true)
      return found if found
    end

    nil
  end
  module_function :home_emphasis_item
end
