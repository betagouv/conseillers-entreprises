class Api::V1::Solicitations::QualificationsController < Api::V1::Solicitations::BaseController
  DEFAULT_PER_PAGE = 100
  MAX_PER_PAGE = 1000
  MAX_BATCH_SIZE = 100

  def unqualified
    solicitations = Solicitation.unqualified.includes(landing_subject: :subject)
    count = solicitations.count
    page = solicitations.page(params[:page]).per(per_page)

    render json: { count: count, solicitations: serialize(page) }, status: :ok
  end

  def update
    qualifications = params.permit(_json: [:id, :qualified, :details])[:_json]
    return render_invalid_batch if qualifications.blank? || qualifications.size > MAX_BATCH_SIZE

    results = qualifications.map { |qualification| apply_qualification(qualification) }

    if results.all? { |result| result[:status] == 200 }
      head :no_content
    else
      render json: results, status: :multi_status
    end
  end

  private

  def apply_qualification(qualification)
    id = qualification[:id]
    qualified = qualification[:qualified]
    return { id: id, status: 400 } if id.blank? || qualified.nil?

    solicitation = Solicitation.find_by(id: id)
    return { id: id, status: 400 } if solicitation.nil? || !solicitation.status_in_progress?

    solicitation.qualify!(qualified: ActiveModel::Type::Boolean.new.cast(qualified), details: qualification[:details])
    { id: id, status: 200 }
  end

  def per_page
    (params[:per_page].presence || DEFAULT_PER_PAGE).to_i.clamp(1, MAX_PER_PAGE)
  end

  def serialize(solicitations)
    ActiveModelSerializers::SerializableResource.new(
      solicitations,
      each_serializer: Api::V1::Solicitations::UnqualifiedSerializer,
      adapter: :attributes
    ).as_json
  end

  def render_invalid_batch
    errors = [
      {
        source: I18n.t('api_pde.errors.invalid_batch.source'),
        message: I18n.t('api_pde.errors.invalid_batch.message', max: MAX_BATCH_SIZE)
      }
    ]
    render_error_payload(errors: errors, status: :bad_request)
  end
end
