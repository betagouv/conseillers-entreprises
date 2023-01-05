# == Schema Information
#
# Table name: institutions_subjects
#
#  id             :bigint(8)        not null, primary key
#  description    :string
#  optional       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)
#  subject_id     :bigint(8)
#
# Indexes
#
#  index_institutions_subjects_on_institution_id  (institution_id)
#  index_institutions_subjects_on_subject_id      (subject_id)
#  index_institutions_subjects_on_updated_at      (updated_at)
#  unique_institution_subject_in_institution      (subject_id,institution_id,description) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class InstitutionSubject < ApplicationRecord
  include WithSubject

  ## Associations
  #
  belongs_to :institution, inverse_of: :institutions_subjects
  belongs_to :subject, inverse_of: :institutions_subjects
  has_many :experts_subjects, dependent: :destroy

  accepts_nested_attributes_for :experts_subjects

  # :subject
  has_one :theme, through: :subject, inverse_of: :institutions_subjects

  # :experts_subjects
  has_many :experts, through: :experts_subjects, inverse_of: :institutions_subjects
  has_many :not_deleted_experts, through: :experts_subjects, inverse_of: :institutions_subjects

  # :institution
  # Other InstitutionSubjects of the same Institution, and the same Subject.
  has_many :similar_institutions_subjects, -> (is) { where(subject: is.subject).where.not(id: is.id) },
           through: :institution, source: :institutions_subjects

  # Validations
  #
  # In an Institution, the same subject can only be selected several times`
  # if the description is different (and present.)
  validates :subject, uniqueness: { scope: [:institution_id, :description] }
  validate :validate_description_presence

  ## Scopes
  #
  scope :support_subjects, -> do
    where(subject: Subject.support_subject)
  end

  ##
  #
  def to_s
    description
  end

  ## Name / Description uniqueness
  #
  def validate_description_presence
    # description mustn't be blank if there’s a similar subject
    if description.blank? && similar_institutions_subjects.present?
      errors.add(:description, :blank)
    end
  end

  ## used for serialization in advisors csv
  #
  def unique_name
    if similar_institutions_subjects.present?
      "#{subject.label}:#{description}" # We know description isn‘t blank, see :validate_description_presence
    else
      subject.label
    end
  end

  def self.find_with_name(institution, name)
    return nil if name.nil?

    clean_name = name.downcase.strip

    matches = institution.institutions_subjects.preload(:subject, :theme).filter do |institution_subject|
      institution_subject.possible_names.include? clean_name
    end

    # return nil if there’s an ambiguity
    matches.first if matches.count == 1
  end

  def possible_names
    [
      "#{theme.label}:#{subject.label}:#{description}".downcase.strip,
      "#{subject.label}:#{description}".downcase.strip,
      description&.downcase.strip,
      subject.label.downcase.strip,
      theme.label.downcase.strip
    ]
  end
end
