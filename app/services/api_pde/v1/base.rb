class ApiPde::V1::Base
  attr_accessor :params, :current_institution

  def initialize(params, current_institution = nil)
    self.params = params
    self.current_institution = current_institution
  end

  private # ====================================================

  def api_transaction
    begin
      ActiveRecord::Base.transaction do
        raise MissingParams if self.params.nil?
        raise MissingParams.new("L'institution concernée est manquante", :institution) if self.current_institution.nil?
        yield
      end
    rescue ActiveRecord::RecordInvalid => e
      invalid_record = e.record
      errors = {
        source: invalid_record.attributes.filter{ |k, v| whitelist_attributes.include?(k) },
        title: "#{invalid_record.class.name} : #{e.class.name}",
        detail: invalid_record.errors.messages
      }
      error_response(errors)
    rescue MissingParams => e # params is empty
      errors = {
        source: e.key,
        title: e.class.name,
        detail: e.message
      }
      error_response(errors)
    rescue Exception => e
      # p e.backtrace
      errors = {
        title: e.class.name,
        detail: e.message
      }
      error_response(errors)
      Sentry.capture_exception(e)
    end
  end

  def institution
    current_institution
  end

  # On ne fait apparaitre dans les erreurs que les champs intéressants
  def whitelist_attributes
    [
      "id"
    ]
  end

  def error_response(errors)
    OpenStruct.new(success?: false,
                   item: nil,
                   errors: errors)
  end
end

class MissingParams < StandardError
  attr_reader :key

  def initialize(msg = "les paramètres ne peuvent être vides", key = :params)
    @key = key
    super(msg)
  end
end
