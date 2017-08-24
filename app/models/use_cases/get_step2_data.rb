# frozen_string_literal: true

module UseCases
  class GetStep2Data
    class << self
      def for_diagnosis(diagnosis)
        questions = Question.all.includes(:category).order(:category_id, :id)
        diagnosed_needs_hash = prepare_diagnosed_need_hash diagnosis.diagnosed_needs
        categories_with_questions = create_categories_with_questions questions, diagnosed_needs_hash
        categories_with_questions << create_question_less_category(diagnosed_needs_hash)
        categories_with_questions.delete_if { |item| item[:questions].empty? }
      end

      private

      def create_categories_with_questions(questions, diagnosed_needs_hash)
        questions_by_category_id = questions.group_by { |question| question.category.id }
        categories_with_questions = questions_by_category_id
                                    .collect { |_k, v| { category: v.first.category.label, questions: v } }
        categories_with_questions.map! { |item| transform_category_with_questions item, diagnosed_needs_hash }
      end

      def transform_category_with_questions(item, diagnosed_needs_hash)
        { category: item[:category], questions: transform_questions(item[:questions], diagnosed_needs_hash) }
      end

      def transform_questions(questions, diagnosed_needs_hash)
        questions.map { |question| create_item_from_question(question, diagnosed_needs_hash[question.id]) }
      end

      def create_item_from_question(question, diagnosis_needs)
        {
          question_id: question.id,
          label: question.label,
          is_selected: !diagnosis_needs&.first&.id.nil?,
          diagnosed_need_id: diagnosis_needs&.first&.id,
          content: diagnosis_needs&.first&.content
        }
      end

      def create_question_less_category(diagnosed_needs_hash)
        diagnosed_need_items = diagnosed_needs_hash
                               .fetch(0, [])
                               .map { |diagnosed_need| create_item_from_diagnosis_needs(diagnosed_need) }
        { category: nil, questions: diagnosed_need_items }
      end

      def create_item_from_diagnosis_needs(diagnosis_need)
        {
          question_id: nil,
          label: diagnosis_need.question_label,
          is_selected: true,
          diagnosed_need_id: diagnosis_need.id,
          content: diagnosis_need.content
        }
      end

      def prepare_diagnosed_need_hash(diagnosed_needs)
        diagnosed_needs.group_by { |diagnosed_need| diagnosed_need.question_id.nil? ? 0 : diagnosed_need.question_id }
      end
    end
  end
end
