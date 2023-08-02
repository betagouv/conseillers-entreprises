class TemoignageGenerator
  include ActionView::Helpers::AssetUrlHelper

  def initialize(subject)
    @subject = subject
  end

  def entry
    @entry ||= I18n.t(@subject, scope: 'temoignages')
  end

  def published?
    entry.present? && entry.is_a?(Hash) && (entry[:published] == true)
  end

  def author
    entry[:author]
  end

  def content
    entry[:content]
  end

  def picture_path
    "temoignages/#{picture_url}"
  end

  private

  def picture_url
    entry[:picture]
  end
end
