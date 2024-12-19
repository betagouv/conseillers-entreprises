module MandatoryAnswers
  extend ActiveSupport::Concern

  included do
    has_many :subject_answers, dependent: :destroy, as: :subject_questionable, inverse_of: :subject_questionable, class_name: 'SubjectAnswer::Item'

    accepts_nested_attributes_for :subject_answers, allow_destroy: false

    validates :subject_answers, presence: true, if: -> { subject_with_additional_questions? }
    validate :correct_subject_answers, if: -> { subject_with_additional_questions? }

    before_validation :remove_unused_subject_answers
  end

  def subject_with_additional_questions?
    if self.is_a?(Solicitation)
      status_in_progress? && self.subject&.subject_questions&.any?
    else
      self.subject&.subject_questions&.any?
    end
  end

  def correct_subject_answers
    if (self.subject_answers.to_set{ |f| f.subject_question_id } != self.subject&.subject_question_ids.to_set)
      errors.add(:subject_answers, :incorrect)
    end
  end

  def remove_unused_subject_answers
    self.subject_answers.where.not(subject_question_id: self.subject&.subject_question_ids).destroy_all
  end
end
