module SolicitationModification
  class Base
    def initialize(solicitation = Solicitation.new, params)
      @params = format_params(params)
      @solicitation = solicitation
    end

    def base_call
      update_subject_answers if @solicitation.subject_answers.present?
      @solicitation.assign_attributes(@params)
      manage_completion_step
    end

    def call
      base_call
      return @solicitation
    end

    def call!
      base_call
      @solicitation.save
      return @solicitation
    end

    private

    def format_params(params)
      params
    end

    # on gère automatiquement les étapes du formulaire de création d'une solicitation
    def manage_completion_step
      return if @solicitation.step_complete?
      next_possible_events = @solicitation.aasm(:status).events(permitted: true).map(&:name)
      @solicitation.send(next_possible_events.first) unless next_possible_events.empty?
    end

    def update_subject_answers
      subject_answers_params = @params[:subject_answers_attributes]
      subject_answers_params.to_h.each_value do |params|
        is = @solicitation.subject_answers.find_by(subject_question_id: params[:subject_question_id])
        is.update(filter_value: params[:filter_value])
      end
      @params[:subject_answers_attributes] = []
    end
  end
end
