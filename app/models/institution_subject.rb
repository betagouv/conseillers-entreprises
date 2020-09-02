# == Schema Information
#
# Table name: institutions_subjects
#
#  id             :bigint(8)        not null, primary key
#  description    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)
#  subject_id     :bigint(8)
#
# Indexes
#
#  index_institutions_subjects_on_institution_id  (institution_id)
#  index_institutions_subjects_on_subject_id      (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class InstitutionSubject < ApplicationRecord
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

  ## Scopes
  #
  scope :support_subjects, -> do
    where(subject: Subject.support_subject)
  end

  scope :ordered_for_interview, -> do
    joins(:subject)
      .merge(Subject.ordered_for_interview)
  end

  ##
  #
  def to_s
    description
  end

  ## used for serialization in advisors csv
  #
  def csv_identifier
    [theme, subject, description].to_csv(col_sep: ':').strip
  end
end
