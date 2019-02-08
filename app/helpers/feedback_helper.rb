module FeedbackHelper
  def raw_feedback_block(text, author = nil, date = nil, id = nil, actions = nil)
    render partial: 'needs/feedback', locals: {
      text: text,
      author: author,
      date: date,
      actions: actions,
      id: id
    }
  end

  def feedback_block(feedback, can_delete)
    if can_delete
      actions = link_to(t('delete'), feedback_path(feedback, params.permit(:access_token)), data: { confirm: t('delete'), remote: true, method: :delete })
    else
      actions = nil
    end

    raw_feedback_block(feedback.description, feedback.match.person.full_name, feedback.created_at, feedback.id, actions)
  end
end
