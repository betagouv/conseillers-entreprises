# frozen_string_literal: true

module UseCases
  class GetStep2Data
    class << self
      def for_diagnosis(diagnosis)
        questions = Question.all.includes(:category).order(:category_id, :id)
        diagnosed_needs_hash = needs_grouped_by_question diagnosis.diagnosed_needs
        categories_with_questions = questions_array_with_categories questions, diagnosed_needs_hash
        categories_with_questions << questions_array_without_category(diagnosed_needs_hash)
        categories_with_questions.delete_if { |item| item[:questions].empty? }
      end

      private

      def needs_grouped_by_question(diagnosed_needs)
        diagnosed_needs.group_by { |diagnosed_need| diagnosed_need.question_id || 0 }
      end

      def questions_array_with_categories(questions, diagnosed_needs_hash)
        questions_by_category_id = questions.group_by { |question| question.category.id }
        categories_with_questions = questions_by_category_id
          .collect { |_k, v| { category: v.first.category.label, questions: v } }
        categories_with_questions.map! { |item| transform_category_questions item, diagnosed_needs_hash }
      end

      def transform_category_questions(item, diagnosed_needs_hash)
        {
          category: item[:category],
          questions: item[:questions].map do |question|
            create_item_from_question(question, diagnosed_needs_hash[question.id])
          end
        }
      end

      def create_item_from_question(question, diagnosed_needs)
        {
          question_id: question.id,
          label: question.label,
          is_selected: !diagnosed_needs&.first&.id.nil?,
          diagnosed_need_id: diagnosed_needs&.first&.id,
          content: diagnosed_needs&.first&.content
        }
      end

      def questions_array_without_category(diagnosed_needs_hash)
        diagnosed_need_items = diagnosed_needs_hash
          .fetch(0, [])
          .map { |diagnosed_need| create_item_from_diagnosed_needs(diagnosed_need) }
        { category: nil, questions: diagnosed_need_items }
      end

      def create_item_from_diagnosed_needs(diagnosed_need)
        {
          question_id: nil,
          label: diagnosed_need.question_label,
          is_selected: true,
          diagnosed_need_id: diagnosed_need.id,
          content: diagnosed_need.content
        }
      end
    end
  end
end
