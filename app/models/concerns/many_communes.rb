module ManyCommunes
  extend ActiveSupport::Concern
  included do
    ## Relations and Validations
    #
    has_and_belongs_to_many :communes

    ## Insee Codes acccessors
    #
    def insee_codes
      communes.pluck(:insee_code)
    end

    def insee_codes=(codes_raw)
      wanted_codes = codes_raw.split(/[,\s]/).delete_if(&:empty?)
      if wanted_codes.any? { |code| code !~ Commune::INSEE_CODE_FORMAT }
        raise 'Invalid city codes'
      end

      wanted_codes.each do |code|
        Commune.find_or_create_by(insee_code: code)
      end

      self.communes = Commune.where(insee_code: wanted_codes)
    end
  end
end
