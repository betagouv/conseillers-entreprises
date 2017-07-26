# frozen_string_literal: true

module DiagnosisHelper
  def classes_for_step(displayed_step, current_step = nil)
    if displayed_step == current_step
      'active'
    elsif displayed_step < current_step
      'completed'
    end
  end

  def categories_with_questions
    questions = Question.all.includes(:category).order(:category_id, :id)
    current_category = nil
    categories_with_questions = []
    i = -1
    questions.each do |question|
      if current_category != question.category
        current_category = question.category
        i += 1
        categories_with_questions[i] = { category: current_category.label, questions: [] }
      end
      categories_with_questions[i][:questions] << question
    end
    categories_with_questions
  end
end
