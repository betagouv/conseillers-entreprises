# == Schema Information
#
# Table name: institutions
#
#  id              :bigint(8)        not null, primary key
#  deleted_at      :datetime
#  logo_sort_order :integer
#  name            :string           not null
#  region_name     :string
#  show_on_list    :boolean          default(FALSE)
#  slug            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_institutions_on_deleted_at  (deleted_at)
#  index_institutions_on_name        (name) UNIQUE
#  index_institutions_on_slug        (slug) UNIQUE
#

class Institution < ApplicationRecord
  include SoftDeletable

  ## Associations
  #
  has_many :antennes, inverse_of: :institution
  has_many :institutions_subjects, inverse_of: :institution
  has_many :landings, inverse_of: :institution

  ## Validations
  #
  validates :name, :slug, presence: true, uniqueness: true
  before_validation :compute_slug

  ## Through Associations
  #
  # :institutions_subjects
  has_many :subjects, through: :institutions_subjects, inverse_of: :institutions, dependent: :destroy
  has_many :themes, through: :institutions_subjects, inverse_of: :institutions

  # :antennes
  has_many :experts, through: :antennes, inverse_of: :institution
  has_many :advisors, through: :antennes, inverse_of: :institution
  has_many :sent_diagnoses, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_needs, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_matches, through: :antennes, inverse_of: :advisor_institution

  has_many :received_matches, through: :antennes, inverse_of: :expert_institution
  has_many :received_needs, through: :antennes, inverse_of: :expert_institutions
  has_many :received_diagnoses, through: :antennes, inverse_of: :expert_institutions

  # :landings
  has_many :solicitations, through: :landings, inverse_of: :institution

  accepts_nested_attributes_for :institutions_subjects, :allow_destroy => true

  ## Scopes
  #
  scope :ordered_logos, -> { not_deleted.where.not(logo_sort_order: nil).order(:logo_sort_order) }

  ## Institution subjects helpers
  #

  # All the subjects that can be assigned to an expert of this institution
  def available_subjects
    institutions_subjects
      .ordered_for_interview
      .includes(:theme)
      .merge(Subject.archived(false))
      .group_by { |is| is.theme } # Enumerable#group_by maintains ordering
  end

  # Find the one subject that matches the passed label
  # return nil if there’s an ambiguity
  def find_institution_subject(label)
    return nil if label.nil?

    clean_label = label.downcase.strip
    matches = institutions_subjects.filter do |is|
      label == is.csv_identifier || clean_label.in?([
        is.description.downcase.strip,
        is.subject.label.downcase.strip,
        is.theme.label.downcase.strip
      ])
    end
    matches.first if matches.count == 1
  end

  ##
  #
  def to_param
    slug
  end

  def to_s
    name
  end

  def compute_slug
    if name.present?
      self.slug = name.parameterize.underscore
    end
  end
end
