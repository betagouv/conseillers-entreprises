# frozen_string_literal: true

module UseCases
  class GetQuestionsForPdf
    class << self
      def perform
        associations = [:category, assistances: [experts: :institution]]
        questions = Question.all.includes(associations).order(:category_id, :id)
        questions_array_with_categories questions
      end

      private

      def questions_array_with_categories(questions)
        questions_by_category_id = questions.group_by { |question| question.category.id }
        categories_with_questions = questions_by_category_id
          .collect { |_k, v| { category: v.first.category.label, questions: v } }
        categories_with_questions.map! { |item| transform_category_questions item }
      end

      def transform_category_questions(item)
        {
          category: item[:category],
          questions: item[:questions].map do |question|
            create_item_from_question(question)
          end
        }
      end

      def create_item_from_question(question)
        {
          label: question.label,
          institutions_list: question.assistances
            .flat_map(&:experts)
            .map(&:institution)
            .map(&:name)
            .uniq.join(', ')
        }
      end
    end
  end
end
