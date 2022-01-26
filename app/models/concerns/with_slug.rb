module WithSlug
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true, uniqueness: true
    before_validation :compute_slug
  end

  def compute_slug
    if slug_field.present? && slug.blank?
      self.slug = slug_field
    end
    format_slug
  end

  def slug_field
    title
  end

  def format_slug
    self.slug = slug.dasherize.parameterize if slug.present?
  end
end
