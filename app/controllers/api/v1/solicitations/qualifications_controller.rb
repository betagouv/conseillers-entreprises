class Api::V1::Solicitations::QualificationsController < Api::V1::Solicitations::BaseController
  DEFAULT_PER_PAGE = 100
  MAX_PER_PAGE = 1000
  MAX_BATCH_SIZE = 100

  def unqualified
    solicitations = Solicitation.unqualified.includes(:landing_subject, diagnosis: { needs: :subject })
    count = solicitations.count
    page = solicitations.page(params[:page]).per(per_page)

    render json: { count: count, solicitations: serialize(page) }, status: :ok
  end

  def update
    qualifications = params.permit(_json: [:id, :qualified, :details])[:_json]
    return render_invalid_batch if qualifications.blank? || qualifications.size > MAX_BATCH_SIZE

    solicitations = Solicitation.where(id: batch_ids(qualifications)).index_by(&:id)
    results = qualifications.map { |qualification| apply_qualification(qualification, solicitations) }

    if results.all? { |result| result[:status] == 200 }
      head :no_content
    else
      render json: results, status: :multi_status
    end
  end

  private

  def batch_ids(qualifications)
    qualifications.filter_map { |qualification| qualification[:id].presence }
  end

  def apply_qualification(qualification, solicitations)
    id = qualification[:id]
    qualified = cast_qualified(qualification[:qualified])
    return invalid_item(id) if id.blank? || qualified.nil?

    solicitation = solicitations[id.to_i]
    return invalid_item(id) if solicitation.nil? || !solicitation.status_in_progress?

    solicitation.qualify!(qualified: qualified, details: qualification[:details])
    { id: id, status: 200 }
  rescue ActiveRecord::ActiveRecordError => e
    Appsignal.send_exception(e)
    invalid_item(id)
  end

  # Le service de qualification est externe : on n'accepte que de vrais booléens,
  # là où ActiveModel::Type::Boolean convertirait "maybe" ou "yes" en true.
  def cast_qualified(qualified)
    return qualified if qualified == true || qualified == false
    return true if qualified == 'true'
    return false if qualified == 'false'

    nil
  end

  def invalid_item(id)
    { id: id, status: 400, message: I18n.t('api_pde.errors.not_qualifiable') }
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
